import 'package:annix/models/anniv.dart';
import 'package:annix/utils/store.dart';
import 'package:audio_service/audio_service.dart';

/// [LyricProvider] is an abstract class that provides methods to search and fetch lyrics.
///
/// The [search] method returns a list of handles that can be used to fetch the lyrics.
abstract class LyricProvider {
  Future<List<LyricSearchResponse>> search(MediaItem item);

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

  Future<String?> get title;
  Future<List<String>?> get artists;
  Future<String?> get album;
}
