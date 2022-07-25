import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:get/get.dart';
import 'package:netease_music_api/netease_music_api.dart';

class LyricProviderNetease extends LyricProvider {
  @override
  Future<List<LyricSearchResponse>> search(Track track) async {
    await NeteaseMusicApi.init();
    final api = NeteaseMusicApi();

    final searchResult = await api.searchSong('${track.title}');
    if (searchResult.codeEnum != RetCode.Ok) {
      Get.snackbar('Lyric Request', searchResult.realMsg);
      return [];
    }
    final songs = searchResult.result.songs;
    if (songs.isEmpty) {
      Get.snackbar('Lyric Request', 'No result');
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
  Future<LyricLanguage?> get lyric async {
    final api = NeteaseMusicApi();
    final songId = song.id;
    final lyricResult = await api.songLyric(songId);
    if (lyricResult.codeEnum != RetCode.Ok) {
      throw lyricResult.realMsg;
    }

    final lyric = lyricResult.lrc;
    if (lyric.lyric != null) {
      return LyricLanguage(
        type: 'lrc',
        language: 'netease',
        data: lyric.lyric!,
      );
    }

    return null;
  }

  @override
  Future<String?> get title => Future.value(song.name);

  @override
  Future<List<String>?> get artists =>
      Future.value(song.artists?.map((e) => e.name!).toList());

  @override
  Future<String?> get album => Future.value(song.album?.name);
}
