import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:netease_music_api/netease_music_api.dart';

class LyricSourceNetease extends LyricSource {
  @override
  Future<List<LyricSearchResponse>> search({
    required final TrackIdentifier track,
    required final String title,
    final String? artist,
    final String? album,
  }) async {
    await NeteaseMusicApi.init();
    final api = NeteaseMusicApi();

    final searchResult = await api.searchSong(title);
    if (searchResult.codeEnum != RetCode.Ok) {
      return [];
    }
    final songs = searchResult.result.songs;
    if (songs.isEmpty) {
      return [];
    }

    return searchResult.result.songs
        .map((final song) => LyricSearchResponseNetease(song))
        .toList();
  }
}

class LyricSearchResponseNetease extends LyricSearchResponse {
  final Song song;

  LyricSearchResponseNetease(this.song);

  @override
  Future<LyricResult> get lyric async {
    final api = NeteaseMusicApi();
    final songId = song.id;
    final lyricResult = await api.songLyric(songId);
    if (lyricResult.codeEnum != RetCode.Ok) {
      throw lyricResult.realMsg;
    }

    final lyric = lyricResult.lrc;
    if (lyric.lyric == null) {
      // FIXME: concrete error
      throw Error();
    }

    final model = LyricsModelBuilder.create().bindLyricToMain(lyric.lyric!);

    if (lyricResult.tlyric.lyric != null) {
      // translated lyric
      model.bindLyricToExt(lyricResult.tlyric.lyric!);
    }

    return LyricResult(
      text: lyric.lyric!,
      model: model.getModel(),
    );
  }

  @override
  String get title => song.name ?? 'No title';

  @override
  List<String> get artists => song.artists?.map((final e) => e.name!).toList() ?? [];

  @override
  Future<String?> get album => Future.value(song.album?.name);
}
