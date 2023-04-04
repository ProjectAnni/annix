import 'package:annix/global.dart';
import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_source_sqlite.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnivSqliteMetadataSource extends SqliteMetadataSource {
  final Ref ref;

  AnnivSqliteMetadataSource(this.ref) : super(Global.dataRoot);

  @override
  Future<bool> canUpdate() async {
    final anniv = ref.read(annivProvider);
    final client = anniv.client;
    if (client == null) {
      return false;
    }

    try {
      final repoDescription = await client.getRepoDatabaseDescription();
      final remoteLastModified = repoDescription.lastModified;
      final localRepoDescription = await getDescription();
      final localLastModified = localRepoDescription.lastModified;
      return remoteLastModified > localLastModified;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> doUpdate() async {
    final anniv = ref.read(annivProvider);
    if (anniv.client == null) {
      return false;
    }

    try {
      await anniv.client?.downloadRepoDatabase(dbFolderPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
