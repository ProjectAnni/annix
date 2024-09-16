# CONTRIBUTING

## Codegen

### Rust

```bash
flutter_rust_bridge_codegen generate --no-web --watch
```

### Dart

```bash
dart run build_runner watch --delete-conflicting-outputs

# Force update i18n
flutter pub run slang
```

## Upgrading database

1. Edit schema defined in `(lib/services/local/tables.drift)`.
2. Increase `schemaVersion`.
3. Dump new schema:
```bash
dart run drift_dev schema dump lib/services/local/database.dart drift_schemas
dart run drift_dev schema steps drift_schemas/ ./lib/services/local/schema_versions.dart
```

## FAQs

### `Could not find a command named "bin/build_tool_runner.dill".`

You should remove the `.package_hash` file. It usually locates in:

```
./build/rust_lib_annix/build/build_tool/.package_hash
./build/macos/Build/Intermediates.noindex/Pods.build/Debug/rust_lib_annix.build/build_tool/.package_hash
```
