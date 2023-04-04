import 'dart:io';

import 'package:annix/global.dart';
import 'package:drift/drift.dart';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(include: {'tables.drift'})
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File(p.join(Global.dataRoot, 'local.db'));
    return NativeDatabase(file);
  });
}
