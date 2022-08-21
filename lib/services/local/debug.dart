import 'package:annix/global.dart';
import 'package:annix/services/local/database.dart';
import 'package:file_local_storage_inspector/file_local_storage_inspector.dart';
import 'package:preferences_local_storage_inspector/preferences_local_storage_inspector.dart';
import 'package:drift_local_storage_inspector/drift_local_storage_inspector.dart';
import 'package:storage_inspector/storage_inspector.dart';

Future<void> startDebug() async {
  final driver = StorageServerDriver(
    bundleId: 'rs.anni.annix',
    port: 0,
    icon: '...',
  );

  final preferencesServer = PreferencesKeyValueServer(
      Global.preferences, 'Base Preferences');
  driver.addKeyValueServer(preferencesServer);

  final fileServer = DefaultFileServer(Global.storageRoot, "Cache files");
  driver.addFileServer(fileServer);

  final driftDb = LocalDatabase();
  final sqlServer = DriftSQLDatabaseServer(
    id: "1",
    name: "SQL server",
    database: driftDb,
  );
  driver.addSQLServer(sqlServer);

  driver.start(paused: false);
}
