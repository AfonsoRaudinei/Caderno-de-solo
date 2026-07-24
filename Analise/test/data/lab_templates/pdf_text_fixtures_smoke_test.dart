import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fixtures de texto nativo versionados existem e contêm marcadores base',
      () {
    final cases = <({String path, String marker})>[
      (
        path: 'test/data/lab_templates/fixtures/mb_78416_2025_native.txt',
        marker: 'ANÁLISE DE SOLO - Nº 78416',
      ),
      (
        path: 'test/data/lab_templates/fixtures/ibra_237526_2025_native.txt',
        marker: 'O.S.: 237526',
      ),
      (
        path: 'test/data/lab_templates/fixtures/sellar_6077_2025_native.txt',
        marker: '6077/2025',
      ),
      (
        path: 'test/data/lab_templates/fixtures/sellar_4517_2026_native.txt',
        marker: '4517/2026',
      ),
    ];

    for (final c in cases) {
      final file = File(c.path);
      expect(file.existsSync(), isTrue, reason: 'Fixture ausente: ${c.path}');
      final text = file.readAsStringSync();
      expect(text.trim(), isNotEmpty, reason: 'Fixture vazio: ${c.path}');
      expect(
        text,
        contains(c.marker),
        reason: 'Marcador base ausente no fixture ${c.path}',
      );
    }
  });
}
