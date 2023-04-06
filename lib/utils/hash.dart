import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

String sha256(final String input) {
  final bytes = utf8.encode(input);
  return crypto.sha256.convert(bytes).toString();
}
