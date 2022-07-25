import 'package:annix/lyric/lyric_provider.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import "dart:typed_data";

class PetitLyricsClient {
  static PetitLyricsClient _instance = PetitLyricsClient._();
  factory PetitLyricsClient() => _instance;
  PetitLyricsClient._();

  Dio _client = Dio();

  Future<XmlDocument> getLyric(Track track,
      {int lyricType = 1, int? lyricId}) async {
    final data = await _client.post(
      "http://p0.petitlyrics.com/api/GetPetitLyricsData.php",
      data: {
        "clientAppId": "p1110417",
        "lyricsType": lyricType,
        "terminalType": 10,
        // "key_artist": track.artist,
        "key_title": track.title,
        "key_album": track.disc.album.title,
        "key_lyricsId": lyricId ?? "",
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return XmlDocument.parse(data.data as String);
  }

  List<String> decrypt(Uint8List encrypted, String text) {
    final lyric = text.split('\n').toList();

    final data = encrypted.buffer.asByteData();
    final projectionId = data.getUint16(0x1a, Endian.little);
    final protectionKeySwitchFlag = data.getUint8(0x19) == 1;

    var projectionKey = projectionId;
    if (protectionKeySwitchFlag) {
      projectionKey = (projectionId & 0x3) |
          (projectionId & 0xc) << 2 |
          (projectionId & 0x30) >> 2 |
          (projectionId & 0xc0) << 2 |
          (projectionId & 0x300) >> 2 |
          (projectionId & 0xc00) << 2 |
          (projectionId & 0x3000) >> 2 |
          (projectionId & 0xc000);
    }

    final lineCount = data.getUint32(0x38, Endian.little);
    // final lineLength = data.getUint16(0x42, Endian.little);

    final List<String> time = [];
    var offset = 0;
    for (var i = 0; i < lineCount; i++) {
      final timeBeginByteindex = i * 2 + 0xcc;
      final timeRaw = data.getUint16(timeBeginByteindex, Endian.little);
      final timeCs = timeRaw ^ projectionKey;

      final line = "[" + cs2mmssff(timeCs + offset * 65536) + "] " + lyric[i];
      print(line);
      time.add(line);
      offset += timeCs ~/ 65536;
    }
    return time;
  }
}

class LyricProviderPetitLyrics extends LyricProvider {
  final _client = PetitLyricsClient();

  @override
  Future<List<LyricSearchResponse>> search(Track track) async {
    // https://github.com/kokarare1212/MusicBee.PetitLyrics/blob/master/MusicBee.PetitLyrics/Plugin.cs
    final document = await _client.getLyric(track);
    final songs = document.findAllElements("song");
    return songs
        .map(
          (song) => LyricSearchResponsePetitLyrics(
            lyricId: int.parse(song.findElements("lyricsId").first.text),
            track: track,
            trackTitle: song.findElements("title").first.text,
            albumTitle: song.findElements("album").first.text,
            artistsName: [song.findElements("artist").first.text],
            lyricText: utf8.decode(
                base64Decode(song.findElements("lyricsData").first.text)),
          ),
        )
        .toList();
  }
}

class LyricSearchResponsePetitLyrics extends LyricSearchResponse {
  final _client = PetitLyricsClient();

  final String? albumTitle;
  final String? trackTitle;
  final List<String>? artistsName;

  int lyricId;
  Track track;
  final String lyricText;

  LyricSearchResponsePetitLyrics({
    required this.lyricId,
    required this.track,
    required this.lyricText,
    this.albumTitle,
    this.trackTitle,
    this.artistsName,
  });

  @override
  Future<String?> get album => Future.value(this.albumTitle);

  @override
  Future<List<String>?> get artists => Future.value(this.artistsName);

  @override
  Future<LyricLanguage?> get lyric async {
    final lrc = await _client.getLyric(
      track,
      lyricType: 2,
      lyricId: this.lyricId,
    );

    final songs = lrc.findAllElements("song");
    if (songs.isEmpty) {
      // lrc not found, return text lyric
      return LyricLanguage(
        language: "--",
        type: "text",
        data: this.lyricText,
      );
    } else {
      final encrypted =
          base64Decode(songs.first.findElements("lyricsData").first.text);
      return LyricLanguage(
        language: "--",
        type: "lrc",
        data: _client.decrypt(encrypted, this.lyricText).join('\n'),
      );
    }
  }

  @override
  Future<String?> get title => Future.value(this.trackTitle);
}

String cs2mmssff(int cs) {
  final ff = (cs % 100).toString().padLeft(2, '0');
  final ss = ((cs ~/ 100) % 60).toString().padLeft(2, '0');
  final mm = ((cs ~/ 6000) % 60).toString().padLeft(2, '0');
  return "$mm:$ss.$ff";
}
