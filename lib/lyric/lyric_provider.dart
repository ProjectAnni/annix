import 'package:annix/models/anniv.dart';
import 'package:annix/utils/store.dart';

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
  Future<List<LyricSearchResponse>> search(String title,
      {String? artist, String? album});

  static final _store = AnnixStore().category('lyric');
  static Future<LyricLanguage?> getLocal(String id) => _store
      .get(id)
      .then((value) => value == null ? null : LyricLanguage.fromJson(value));

  static Future<void> saveLocal(String id, LyricLanguage lyric) =>
      _store.set(id, lyric.toJson());
}

/// [LyricSearchResponse] is the response of [LyricProvider.search].
abstract class LyricSearchResponse {
  Future<LyricLanguage?> get lyric;

  String get title;
  List<String> get artists;
  Future<String?> get album;
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
  Future<LyricLanguage?> get lyric => Future.value(LyricLanguage(
        language: "--",
        type: lyricType,
        data: lyricText,
      ));

  @override
  String get title => trackTitle;
}
