import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/models/anniv.dart';
import 'package:netease_music_api/netease_music_api.dart';

class LyricProviderNetease extends LyricProvider {
  @override
  Future<List<LyricSearchResponse>> search({
    required TrackIdentifier track,
    required String title,
    String? artist,
    String? album,
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
        .map((song) => LyricSearchResponseNetease(song))
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

    return LyricResult(
      text: lyric.lyric!,
    );
  }

  @override
  String get title => song.name ?? "No title";

  @override
  List<String> get artists => song.artists?.map((e) => e.name!).toList() ?? [];

  @override
  Future<String?> get album => Future.value(song.album?.name);
}
