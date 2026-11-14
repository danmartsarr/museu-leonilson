import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every artwork in acervo.json points to an existing image', () {
    final obras = jsonDecode(File('assets/acervo.json').readAsStringSync()) as List;
    for (final o in obras) {
      expect(File(o['path'] as String).existsSync(), isTrue, reason: o['path'] as String);
    }
  });
}
