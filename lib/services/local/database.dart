import 'dart:io';

import 'package:annix/services/path.dart';
import 'package:drift/drift.dart';

import 'package:drift/native.dart';

part 'database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(localDbPath());
    return NativeDatabase(file);
  });
}
