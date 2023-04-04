import 'package:annix/providers.dart';
import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LyricSourceAnniv extends LyricSource {
  final Ref<Object?> ref;

  LyricSourceAnniv(this.ref);

  @override
  Future<List<LyricSearchResponse>> search({
    required final TrackIdentifier track,
    required final String title,
    final String? artist,
    final String? album,
  }) async {
    final anniv = ref.read(annivProvider);
    final lyric = await anniv.client!.getLyric(track);
    final source = lyric?.source;
    if (source == null) {
      return [];
    }
    return [
      LyricSearchResponseAnniv(
        source.type,
        source.data,
        titleText: title,
        artistText: artist,
        albumText: album,
      )
    ];
  }
}

class LyricSearchResponseAnniv extends LyricSearchResponse {
  final String type;
  final String text;

  final String titleText;
  final String? artistText;
  final String? albumText;

  LyricSearchResponseAnniv(
    this.type,
    this.text, {
    required this.titleText,
    this.artistText,
    this.albumText,
  });

  @override
  Future<LyricResult> get lyric async {
    // TODO: karaoke format
    final model = LyricsModelBuilder.create().bindLyricToMain(text).getModel();

    return LyricResult(
      text: text,
      model: model,
    );
  }

  @override
  String get title => titleText;

  @override
  List<String> get artists => artistText == null ? [] : [artistText!];

  @override
  Future<String?> get album => Future.value(albumText);
}
