import 'package:annix/models/anniv.dart';

class TagEntry extends TagInfo {
  final List<String> children;

  TagEntry({required this.children, required super.name, required super.type});
}
