/// MetadataSource is the source of local metadata need by the whole application.
///
/// It can be folder with structure defined in [Anni Metadata Repository][metadata-repository], or pre-compiled sqlite database file.
///
/// [metadata-repository]: https://book.anni.rs/02.metadata-repository/00.readme.html
abstract class BaseMetadataSource {
  /// Prepare for metadata source
  Future<void> prepare();

  /// Update metadata source by calling [doUpdate]
  ///
  /// [doUpdate] might be called when caller [force] to update,
  /// or when [canUpdate] returns true
  ///
  /// This function returns whether an update is done actually.
  Future<bool> update({force = false}) async {
    if (force || await canUpdate()) {
      return await doUpdate();
    }
    return false;
  }

  /// Controls whether to update metadata when not forced
  Future<bool> canUpdate() async {
    return false;
  }

  /// The actual update part. Override this function with actual implementation.
  Future<bool> doUpdate() async {
    return false;
  }
}

enum MetadataSoruceType {
  /// Remote git repository
  GitRemote,

  /// Local git repository
  GitLocal,

  /// Downloadable remote zip file
  Zip,

  /// Prebuilt Database file
  Database,

  /// Local folder
  Folder,
}
