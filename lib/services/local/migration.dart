import 'package:annix/services/local/schema_versions.dart';
import 'package:drift/drift.dart';

MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // Added last_updated to local_annil_caches
        await m.addColumn(
            schema.localAnnilCaches, schema.localAnnilCaches.lastUpdate);
      },
    ),
  );
}
