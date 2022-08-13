import 'dart:convert';

import 'package:annix/models/anniv.dart';
import 'package:annix/utils/store.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

enum LyricProviders {
  // ignore: constant_identifier_names
  PetitLyrics,
  // ignore: constant_identifier_names
  Netease,
}

/// [LyricProvider] is an abstract class that provides methods to search and fetch lyrics.
///
/// The [search] method returns a list of handles that can be used to fetch the lyrics.
abstract class LyricProvider {
  Future<List<LyricSearchResponse>> search({
    required TrackIdentifier track,
    required String title,
    String? artist,
    String? album,
  });

  static final _store = AnnixStore().category('lyric');
  static Future<LyricResult?> getLocal(String id) => _store
      .get(id)
      .then((value) => value == null ? null : LyricResult.fromJson(value));

  static Future<void> saveLocal(String id, LyricResult lyric) =>
      _store.set(id, lyric.toJson());
}

/// [LyricSearchResponse] is the response of [LyricProvider.search].
abstract class LyricSearchResponse {
  String get title;
  List<String> get artists;
  Future<String?> get album;

  Future<LyricResult> get lyric;
}

class LyricSearchResponseText extends LyricSearchResponse {
  final String? albumTitle;
  final String trackTitle;
  final List<String> artistsName;
  final String lyricText;
  final String lyricType;

  LyricSearchResponseText({
    this.albumTitle,
    required this.trackTitle,
    this.artistsName = const [],
    required this.lyricText,
    this.lyricType = "text",
  });

  @override
  Future<String?> get album => Future.value(albumTitle);

  @override
  List<String> get artists => artistsName;

  @override
  Future<LyricResult> get lyric => Future.value(LyricResult(text: lyricText));

  @override
  String get title => trackTitle;
}

class LyricResult {
  LyricsReaderModel? model;
  String text;

  LyricResult({
    required this.text,
    this.model,
  });

  factory LyricResult.empty() {
    return LyricResult(text: "");
  }

  bool get isEmpty => text.isEmpty && model.isNullOrEmpty;

  factory LyricResult.fromJson(dynamic json) {
    if (json is String) {
      json = jsonDecode(json);
    }

    final text = json["text"] as String;
    final modelJson = json["model"] as List<dynamic>?;
    return LyricResult(
      text: text,
      model: modelJson == null
          ? null
          : (LyricsModelBuilder.create()
                ..mainLines = modelJson.map((lineJson) {
                  final line = LyricsLineModel();
                  line.startTime = lineJson["startTime"];
                  line.mainText = lineJson["mainText"];

                  if (lineJson["spanList"] != null) {
                    final spans = lineJson["spanList"] as List<dynamic>;
                    line.spanList = spans.map((spanJson) {
                      final span = LyricSpanInfo();
                      span.index = spanJson["index"];
                      span.start = spanJson["start"];
                      span.duration = spanJson["duration"];
                      span.length = spanJson["length"];
                      span.raw = spanJson["raw"];
                      return span;
                    }).toList();
                  }
                  return line;
                }).toList())
              .getModel(),
    );
  }

  String toJson() {
    final json = <String, dynamic>{};
    json["text"] = text;
    if (model == null) {
      json["model"] = null;
    } else {
      json["model"] = model!.lyrics.map((line) {
        final lineJson = <String, dynamic>{};
        lineJson["startTime"] = line.startTime;
        lineJson["mainText"] = line.mainText;
        lineJson["extText"] = line.extText;

        if (line.spanList == null) {
          lineJson["spanList"] = null;
        } else {
          lineJson["spanList"] = line.spanList!.map((span) {
            final spanJson = <String, dynamic>{};
            spanJson["index"] = span.index;
            spanJson["start"] = span.start;
            spanJson["duration"] = span.duration;
            spanJson["length"] = span.length;
            spanJson["raw"] = span.raw;
            return spanJson;
          }).toList();
        }
        return lineJson;
      }).toList();
    }
    return jsonEncode(json);
  }
}
