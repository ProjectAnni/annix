# CONTRIBUTING

## Codegen

### Rust

```bash
flutter_rust_bridge_codegen generate --no-web --watch
```

### Dart

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Upgrading database

1. Edit schema defined in `(lib/services/local/tables.drift)`.
2. Increase `schemaVersion`.
3. Dump new schema:
```bash
dart run drift_dev schema dump lib/services/local/database.dart drift_schemas
dart run drift_dev schema steps drift_schemas/
```