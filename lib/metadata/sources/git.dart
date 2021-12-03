import 'dart:io';

import 'package:annix/metadata/sources/file.dart';

class GitMetadataSource extends FileMetadataSource {
  String? remoteSource;

  GitMetadataSource._({this.remoteSource, required String localSource})
      : super(localSource: localSource);

  static GitMetadataSource local(String localSource) {
    return GitMetadataSource._(localSource: localSource);
  }

  static GitMetadataSource remote(String remoteSource) {
    var localSource = '/tmp/metadata';
    return GitMetadataSource._(
        localSource: localSource, remoteSource: remoteSource);
  }

  @override
  Future<void> prepare() async {
    if (!await Directory(localSource).exists()) {
      // local source does not exist, try to clone remoteSource to local
      if (remoteSource != null) {
        // TODO: clone repository
        throw UnimplementedError();
      } else {
        // remote source is null, this is a local git source
        // throw DirectoryNotFound exception
        throw new Exception("Folder not found");
      }
    }
  }

  @override
  Future<bool> canUpdate() async {
    // a git metadata source can update only if it has a remote git source
    return remoteSource != null;
  }

  @override
  Future<bool> doUpdate() async {
    // TODO: git pull
    throw UnimplementedError();
  }
}
