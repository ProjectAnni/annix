import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import "dart:typed_data";

class PetitLyricsClient {
  static final PetitLyricsClient _instance = PetitLyricsClient._();
  factory PetitLyricsClient() => _instance;
  PetitLyricsClient._();

  final Dio _client = Dio();

  Future<XmlDocument> getLyric(String title,
      {String? artist, String? album, int lyricType = 1, int? lyricId}) async {
    final data = await _client.post(
      "http://p0.petitlyrics.com/api/GetPetitLyricsData.php",
      data: {
        "clientAppId": "p1110417",
        "lyricsType": lyricType,
        "terminalType": 10,
        "key_artist": artist,
        "key_title": title,
        "key_album": album,
        "key_lyricsId": lyricId ?? "",
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return XmlDocument.parse(data.data as String);
  }

  Future<XmlDocument> getLyricById(int lyricId, {int lyricType = 1}) async {
    final data = await _client.post(
      "http://p0.petitlyrics.com/api/GetPetitLyricsData.php",
      data: {
        "clientAppId": "p1110417",
        "lyricsType": lyricType,
        "terminalType": 10,
        "key_lyricsId": lyricId,
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

    // add empty lines
    while (lyric.length < lineCount) {
      lyric.add("");
    }

    final List<String> time = [];
    var offset = 0;
    for (var i = 0; i < lineCount; i++) {
      final timeBeginByteindex = i * 2 + 0xcc;
      final timeRaw = data.getUint16(timeBeginByteindex, Endian.little);
      final timeCs = timeRaw ^ projectionKey;

      final line = "[${cs2mmssff(timeCs + offset * 65536)}] ${lyric[i]}";
      time.add(line);
      offset += timeCs ~/ 65536;
    }
    return time;
  }
}

class LyricProviderPetitLyrics extends LyricProvider {
  final _client = PetitLyricsClient();

  @override
  Future<List<LyricSearchResponse>> search({
    required TrackIdentifier track,
    required String title,
    String? artist,
    String? album,
  }) async {
    // https://github.com/kokarare1212/MusicBee.PetitLyrics/blob/master/MusicBee.PetitLyrics/Plugin.cs
    final document = await _client.getLyric(
      title,
      artist: artist,
      album: album,
      lyricType: 3,
    );
    final songs = document.findAllElements("song");
    return songs.map(
      (song) {
        final lyricType = int.parse(song.findElements("lyricsType").first.text);
        final lyricData = song.findElements("lyricsData").first.text;
        return LyricSearchResponsePetitLyrics(
          lyricId: int.parse(song.findElements("lyricsId").first.text),
          lyricType: lyricType,
          trackTitle: song.findElements("title").first.text,
          albumTitle: song.findElements("album").first.text,
          artistsName: [song.findElements("artist").first.text],
          lyricText:
              lyricType != 2 ? utf8.decode(base64Decode(lyricData)) : lyricData,
        );
      },
    ).toList();
  }
}

class LyricSearchResponsePetitLyrics extends LyricSearchResponse {
  final _client = PetitLyricsClient();

  final String? albumTitle;
  final String trackTitle;
  final List<String> artistsName;

  int lyricId;
  int? lyricType;
  final String lyricText;

  LyricSearchResponsePetitLyrics({
    required this.lyricId,
    required this.lyricText,
    this.lyricType,
    this.albumTitle,
    required this.trackTitle,
    required this.artistsName,
  });

  @override
  Future<String?> get album => Future.value(albumTitle);

  @override
  List<String> get artists => artistsName;

  @override
  Future<LyricResult> get lyric async {
    if (lyricType == 1) {
      // lrc not found, return text lyric
      return LyricResult(
        text: lyricText,
      );
    } else if (lyricType == 2) {
      // lrc
      final text = await _client.getLyricById(lyricId, lyricType: 1);

      final songs = text.findAllElements("song");
      final lyricPlainText = utf8.decode(
          base64Decode(songs.first.findElements("lyricsData").first.text));
      final encrypted = base64Decode(lyricText);
      return LyricResult(
        text: lyricPlainText,
        model: LyricsModelBuilder.create()
            .bindLyricToMain(
              _client.decrypt(encrypted, lyricPlainText).join('\n'),
            )
            .getModel(),
      );
    } else {
      // lyric type = 3, karaoke
      final xml = XmlDocument.parse(lyricText);
      final lines = xml
          .findAllElements("line")
          .map((line) => WsyLyricLine.fromXml(line))
          .toList();

      final linesModel = lines.map((line) {
        final lineModel = LyricsLineModel();
        lineModel.mainText = line.words.map((e) => e.text).join();
        lineModel.startTime = line.words.first.startTime;

        int index = 0;
        lineModel.spanList = line.words.map((word) {
          final span = LyricSpanInfo();
          span.raw = word.text;
          span.length = span.raw.length;

          span.index = index;

          span.start = word.startTime;
          span.duration = word.endTime - word.startTime;
          index += span.length;
          return span;
        }).toList();

        return lineModel;
      }).toList();

      final model =
          (LyricsModelBuilder.create()..mainLines = linesModel).getModel();
      final lyric = lines.map((e) => e.toString()).join("\n");
      return LyricResult(
        text: lyric,
        model: model,
      );
    }
  }

  @override
  String get title => trackTitle;
}

String cs2mmssff(int cs) {
  final ff = (cs % 100).toString().padLeft(2, '0');
  final ss = ((cs ~/ 100) % 60).toString().padLeft(2, '0');
  final mm = ((cs ~/ 6000) % 60).toString().padLeft(2, '0');
  return "$mm:$ss.$ff";
}

class WsyLyricLine {
  final List<WsyLyricWord> words;

  WsyLyricLine(this.words);

  factory WsyLyricLine.fromXml(XmlElement line) {
    final words = line
        .findAllElements("word")
        .map((word) => WsyLyricWord.fromXml(word))
        .toList();
    return WsyLyricLine(words);
  }

  @override
  String toString() {
    return "[${words.first.startTime},${words.last.endTime - words.first.startTime}]${words.map((e) => e.toString()).join("")}";
  }
}

class WsyLyricWord {
  final String text;
  final int startTime;
  final int endTime;

  WsyLyricWord({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  factory WsyLyricWord.fromXml(XmlElement word) {
    return WsyLyricWord(
      text: word.getElement("wordstring")!.text,
      startTime: int.parse(word.getElement("starttime")!.text),
      endTime: int.parse(word.getElement("endtime")!.text),
    );
  }

  @override
  String toString() {
    if (startTime == endTime) {
      return "";
    }
    return "$text($startTime,${endTime - startTime})";
  }
}
