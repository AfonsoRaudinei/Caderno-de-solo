import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('analiseDataSourceProvider limita mock a builds fora de release', () {
    final file = File(
      '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart',
    );
    final content = file.readAsStringSync();

    expect(content.contains('if (AppConfig.allowAnaliseMockMode)'), isTrue);
    expect(
      content.contains('return ref.watch(analiseFirestoreDatasourceProvider);'),
      isTrue,
    );
    expect(
        content.contains('return ref.watch(analiseLocalDatasourceProvider);'),
        isTrue);
  });
}
