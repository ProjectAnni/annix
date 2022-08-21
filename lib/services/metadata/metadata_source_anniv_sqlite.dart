import 'package:annix/global.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/metadata/metadata_source_sqlite.dart';
import 'package:provider/provider.dart';

class AnnivSqliteMetadataSource extends SqliteMetadataSource {
  AnnivSqliteMetadataSource() : super(Global.dataRoot);

  @override
  Future<bool> canUpdate() async {
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);
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
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);

    try {
      await anniv.client?.downloadRepoDatabase(dbPath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
