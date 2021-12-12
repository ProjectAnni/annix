import 'dart:io';

import 'package:annix/metadata/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:path/path.dart' as path;
import 'package:toml/toml.dart';

class FileMetadataSource extends BaseMetadataSource {
  String localSource;

  FileMetadataSource({required this.localSource});

  @override
  Future<void> prepare() async {
    if (!await Directory(localSource).exists()) {
      // local source does not exist
      // throw DirectoryNotFound exception
      throw new Exception("Folder not found");
    }
  }

  @override
  Future<Album?> getAlbumDetail({required String catalog}) async {
    final file = File(path.join(localSource, 'album', '$catalog.toml'));
    if (!await file.exists()) {
      return null;
    }

    try {
      final toml = TomlDocument.parse(await file.readAsString());
      return Album.fromMap(toml.toMap());
    } on TomlParserException catch (e) {
      print(e);
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
