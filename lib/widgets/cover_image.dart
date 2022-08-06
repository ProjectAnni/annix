import 'dart:async';
import 'dart:io' show File, HttpServer, InternetAddress, ContentType;

import 'package:annix/services/global.dart';
import 'package:annix/utils/theme.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_plus/http_plus.dart';
import 'package:material_color_utilities/quantize/quantizer_celebi.dart';
import 'package:material_color_utilities/score/score.dart';
import 'package:path/path.dart' as p;

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}

class CoverItem {
  final String albumId;
  final int? discId;
  final Uri? uri;

  CoverItem({
    required this.albumId,
    this.discId,
    this.uri,
  });

  String get key => '$albumId/$discId';
}

class CoverReverseProxy {
  static final client = HttpPlusClient(enableHttp2: false);
  static CoverReverseProxy? _instance;

  late HttpServer proxy;
  final Map<String, CoverItem> _urlMap = Map();
  final downloadingMap = Map();

  Future<void> setup() {
    return HttpServer.bind(InternetAddress.loopbackIPv4, 0).then((server) {
      proxy = server;
      proxy.listen((request) async {
        if (request.method == 'GET') {
          var path = request.uri.path;
          if (path.startsWith('/')) {
            path = path.substring(1);
          }
          final coverItem = _urlMap[path];
          if (coverItem != null) {
            try {
              final cover = await getCoverImage(coverItem);
              if (cover != null) {
                request.response.statusCode = 200;
                request.response.headers.contentType =
                    ContentType.parse('image/jpg');
                await request.response.addStream(cover.openRead());
                return;
              }
            } finally {
              await request.response.close();
            }
          } else {
            request.response.statusCode = 404;
          }

          request.response.close();
          return;
        }
      });
    });
  }

  CoverReverseProxy._();

  factory CoverReverseProxy() {
    if (_instance == null) {
      _instance = CoverReverseProxy._();
    }
    return _instance!;
  }

  Uri url(CoverItem remote) {
    final key = remote.key;
    _urlMap[key] ??= remote;
    return Uri(scheme: 'http', host: "127.0.0.1", port: proxy.port, path: key);
  }

  Future<File?> getCoverImage(CoverItem cover) async {
    if (downloadingMap.containsKey(cover.uri.toString())) {
      await downloadingMap[cover.uri.toString()];
    }

    final coverImagePath = getCoverCachePath(cover.albumId, cover.discId);
    final file = File(coverImagePath);
    if (!await file.exists()) {
      if (cover.uri == null) {
        return null;
      }

      // fetch remote cover
      final getRequest = client.get(cover.uri!);
      downloadingMap[cover.uri.toString()] = getRequest;
      final response = await getRequest;
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        // response stream to Uint8List
        final data = response.bodyBytes;
        await file.writeAsBytes(data);
        downloadingMap.remove(cover.uri.toString());
      }
    }
    return file;
  }
}

class CoverImage extends StatelessWidget {
  final String? albumId;
  final int? discId;
  final Uri? remoteUrl;

  final BoxFit? fit;
  final FilterQuality filterQuality;
  final String? tag;

  const CoverImage({
    Key? key,
    this.remoteUrl,
    this.albumId,
    this.discId,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
  }) : super(key: key);

  Widget dummy() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (albumId == null) {
      return dummy();
    } else {
      return Hero(
        tag: "${tag ?? ""}/$albumId/$discId",
        child: ThemedImage(
          CoverReverseProxy()
              .url(
                CoverItem(
                  uri: remoteUrl,
                  albumId: albumId!,
                  discId: discId,
                ),
              )
              .toString(),
          fit: fit,
          filterQuality: filterQuality,
          cacheHeight: 800,
          gaplessPlayback: true,
          cache: false,
        ),
      );
    }
  }
}

class ThemedImage extends StatelessWidget {
  static Map<String, Completer<Color>> colors = Map();

  ThemedImage(
    String url, {
    Key? key,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.loadStateChanged,
    this.shape,
    this.border,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.enableLoadState = true,
    this.beforePaintImage,
    this.afterPaintImage,
    this.mode = ExtendedImageMode.none,
    this.enableMemoryCache = true,
    this.clearMemoryCacheIfFailed = true,
    this.onDoubleTap,
    this.initGestureConfigHandler,
    this.enableSlideOutPage = false,
    BoxConstraints? constraints,
    CancellationToken? cancelToken,
    int retries = 3,
    Duration? timeLimit,
    Map<String, String>? headers,
    bool cache = true,
    double scale = 1.0,
    Duration timeRetry = const Duration(milliseconds: 100),
    this.extendedImageEditorKey,
    this.initEditorConfigHandler,
    this.heroBuilderForSlidingPage,
    this.clearMemoryCacheWhenDispose = false,
    this.handleLoadingProgress = false,
    this.extendedImageGestureKey,
    int? cacheWidth,
    int? cacheHeight,
    this.isAntiAlias = false,
    String? cacheKey,
    bool printError = true,
    double? compressionRatio,
    int? maxBytes,
    bool cacheRawData = false,
    String? imageCacheName,
    Duration? cacheMaxAge,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })  : assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0),
        image = ExtendedResizeImage.resizeIfNeeded(
          provider: ExtendedNetworkImageProvider(
            url,
            scale: scale,
            headers: headers,
            cache: cache,
            cancelToken: cancelToken,
            retries: retries,
            timeRetry: timeRetry,
            timeLimit: timeLimit,
            cacheKey: cacheKey,
            printError: printError,
            cacheRawData: cacheRawData,
            imageCacheName: imageCacheName,
            cacheMaxAge: cacheMaxAge,
          ),
          compressionRatio: compressionRatio,
          maxBytes: maxBytes,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          cacheRawData: cacheRawData,
          imageCacheName: imageCacheName,
        ),
        assert(constraints == null || constraints.debugAssertIsValid()),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        assert(cacheWidth == null || cacheWidth > 0),
        assert(cacheHeight == null || cacheHeight > 0) {
    final color = colors[url];
    if (color != null) {
      // TODO: on error
      // FIXME: set color only on current playing changes
      color.future.then((c) => AnnixTheme().setTheme(c));
      return;
    }

    final completer = Completer<Color>();
    colors[url] = completer;

    final stream = image.resolve(ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) async {
        final bytes = (await info.image.toByteData())!;
        final top = await compute(getColorFromImage, bytes);
        print(top.toRadixString(16));

        completer.complete(Color(top));
        AnnixTheme().setTheme(Color(top));
      },
      onError: (exception, stackTrace) =>
          completer.completeError(exception, stackTrace),
    );

    stream.addListener(listener);
  }

  /// key of ExtendedImageGesture
  final Key? extendedImageGestureKey;

  /// whether handle loading progress for network
  final bool handleLoadingProgress;

  /// when image is removed from the tree permanently, whether clear memory cache
  final bool clearMemoryCacheWhenDispose;

  /// build Hero only for sliding page
  final HeroBuilderForSlidingPage? heroBuilderForSlidingPage;

  /// init EditConfig when image is ready.
  final InitEditorConfigHandler? initEditorConfigHandler;

  /// key of ExtendedImageEditor
  final Key? extendedImageEditorKey;

  /// whether enable slide out page
  /// you should make sure this is in [ExtendedImageSlidePage]
  final bool enableSlideOutPage;

  ///init GestureConfig when image is ready.
  final InitGestureConfigHandler? initGestureConfigHandler;

  ///call back of double tap  under ExtendedImageMode.gesture
  final DoubleTap? onDoubleTap;

  ///whether cache in PaintingBinding.instance.imageCache
  final bool enableMemoryCache;

  ///when failed to load image, whether clear memory cache
  ///if true, image will reload in next time.
  final bool clearMemoryCacheIfFailed;

  /// image mode (none,gesture)
  final ExtendedImageMode mode;

  ///you can paint anything if you want before paint image.
  ///it's to used in  [ExtendedRawImage]
  ///and [ExtendedRenderImage]
  final BeforePaintImage? beforePaintImage;

  ///you can paint anything if you want after paint image.
  ///it's to used in  [ExtendedRawImage]
  ///and [ExtendedRenderImage]
  final AfterPaintImage? afterPaintImage;

  ///whether has loading or failed state
  ///default is false
  ///but network image is true
  ///better to set it's true when your image is big and take some time to ready
  final bool enableLoadState;

  /// {@macro flutter.clipper.clipBehavior}
  final Clip clipBehavior;

  /// The shape to fill the background [color], [gradient], and [image] into and
  /// to cast as the [boxShadow].
  ///
  /// If this is [BoxShape.circle] then [borderRadius] is ignored.
  ///
  /// The [shape] cannot be interpolated; animating between two [BoxDecoration]s
  /// with different [shape]s will result in a discontinuity in the rendering.
  /// To interpolate between two shapes, consider using [ShapeDecoration] and
  /// different [ShapeBorder]s; in particular, [CircleBorder] instead of
  /// [BoxShape.circle] and [RoundedRectangleBorder] instead of
  /// [BoxShape.rectangle].
  final BoxShape? shape;

  /// A border to draw above the background [color], [gradient], or [image].
  ///
  /// Follows the [shape] and [borderRadius].
  ///
  /// Use [Border] objects to describe borders that do not depend on the reading
  /// direction.
  ///
  /// Use [BoxBorder] objects to describe borders that should flip their left
  /// and right edges based on whether the text is being read left-to-right or
  /// right-to-left.
  final BoxBorder? border;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  final BorderRadius? borderRadius;

  /// custom load state widget if you want
  final LoadStateChanged? loadStateChanged;

  /// The image to display.
  final ImageProvider image;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  ///
  /// It is strongly recommended that either both the [width] and the [height]
  /// be specified, or that the widget be placed in a context that sets tight
  /// layout constraints, so that the image does not change size as it loads.
  /// Consider using [fit] to adapt the image's rendering to fit the given width
  /// and height if the exact image dimensions are not known in advance.
  final double? height;

  final BoxConstraints? constraints;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// If non-null, the value from the [Animation] is multiplied with the opacity
  /// of each image pixel before painting onto the canvas.
  ///
  /// This is more efficient than using [FadeTransition] to change the opacity
  /// of an image, since this avoids creating a new composited layer. Composited
  /// layers may double memory usage as the image is painted onto an offscreen
  /// render target.
  ///
  /// See also:
  ///
  ///  * [AlwaysStoppedAnimation], which allows you to create an [Animation]
  ///    from a single opacity value.
  final Animation<double>? opacity;

  /// Used to set the [FilterQuality] of the image.
  ///
  /// Use the [FilterQuality.low] quality setting to scale the image with
  /// bilinear interpolation, or the [FilterQuality.none] which corresponds
  /// to nearest-neighbor.
  final FilterQuality filterQuality;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  final BlendMode? colorBlendMode;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// To display a subpart of an image, consider using a [CustomPainter] and
  /// [Canvas.drawImageRect].
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final Alignment alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect? centerSlice;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the 'normal' painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes.
  final bool gaplessPlayback;

  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and
  /// VoiceOver on iOS.
  final String? semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// Whether to paint the image with anti-aliasing.
  ///
  /// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.
  final bool isAntiAlias;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      image: image,
      width: this.width,
      height: this.height,
      color: this.color,
      opacity: this.opacity,
      colorBlendMode: this.colorBlendMode,
      fit: this.fit,
      alignment: this.alignment,
      repeat: this.repeat,
      centerSlice: this.centerSlice,
      matchTextDirection: this.matchTextDirection,
      gaplessPlayback: this.gaplessPlayback,
      filterQuality: this.filterQuality,
      loadStateChanged: this.loadStateChanged,
      shape: this.shape,
      border: this.border,
      borderRadius: this.borderRadius,
      clipBehavior: this.clipBehavior,
      enableLoadState: this.enableLoadState,
      beforePaintImage: this.beforePaintImage,
      afterPaintImage: this.afterPaintImage,
      mode: this.mode,
      enableMemoryCache: this.enableMemoryCache,
      clearMemoryCacheIfFailed: this.clearMemoryCacheIfFailed,
      onDoubleTap: this.onDoubleTap,
      initGestureConfigHandler: this.initGestureConfigHandler,
      enableSlideOutPage: this.enableSlideOutPage,
      extendedImageEditorKey: extendedImageEditorKey,
      initEditorConfigHandler: initEditorConfigHandler,
      heroBuilderForSlidingPage: heroBuilderForSlidingPage,
      clearMemoryCacheWhenDispose: clearMemoryCacheWhenDispose,
      handleLoadingProgress: handleLoadingProgress,
      extendedImageGestureKey: extendedImageGestureKey,
      isAntiAlias: isAntiAlias,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
    );
  }
}

int argbFromRgb(int red, int green, int blue) {
  return (255 << 24 | (red & 255) << 16 | (green & 255) << 8 | blue & 255) >>>
      0;
}

Future<int> getColorFromImage(ByteData bytes) async {
  final List<int> pixels = [];
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    final r = bytes.getUint8(i);
    final g = bytes.getUint8(i + 1);
    final b = bytes.getUint8(i + 2);
    final a = bytes.getUint8(i + 3);
    if (a < 255) {
      continue;
    }
    final argb = argbFromRgb(r, g, b);
    pixels.add(argb);
  }
  final result = await QuantizerCelebi().quantize(pixels, 128);
  final ranked = Score.score(result.colorToCount);
  final top = ranked[0];
  return top;
}
