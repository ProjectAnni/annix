import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/models/anniv.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:provider/provider.dart';

class LyricProviderAnniv extends LyricProvider {
  final _anniv = Provider.of<AnnivController>(Global.context, listen: false);

  @override
  Future<List<LyricSearchResponse>> search({
    required TrackIdentifier track,
    required String title,
    String? artist,
    String? album,
  }) async {
    final lyric = await _anniv.client!.getLyric(track);
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
