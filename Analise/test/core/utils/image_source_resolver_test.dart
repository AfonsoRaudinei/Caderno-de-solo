import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/utils/image_source_resolver.dart';

void main() {
  group('ImageSourceResolver', () {
    test('cria FileImage para caminho local existente', () async {
      final tempDir = await Directory.systemTemp.createTemp('image-resolver');
      final file = File('${tempDir.path}/logo.png');
      await file.writeAsBytes(_pngBytes, flush: true);

      final provider = ImageSourceResolver.imageProvider(file.path);

      expect(provider, isA<FileImage>());
    });

    test('converte caminho local em data uri', () async {
      final tempDir = await Directory.systemTemp.createTemp('image-data-uri');
      final file = File('${tempDir.path}/assinatura.png');
      await file.writeAsBytes(_pngBytes, flush: true);

      final dataUri = await ImageSourceResolver.toDataUri(file.path);

      expect(dataUri, isNotNull);
      expect(dataUri, startsWith('data:image/png;base64,'));
    });
  });
}

final List<int> _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wn2XJ8AAAAASUVORK5CYII=',
);
