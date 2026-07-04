import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/utils/firestore_doc_id.dart';

void main() {
  group('sanitizeFirestoreDocId', () {
    test('substitui barra por underscore', () {
      expect(sanitizeFirestoreDocId('6077/2025-54215'), '6077_2025-54215');
    });

    test('preserva ids sem caracteres invalidos', () {
      expect(sanitizeFirestoreDocId('237526-257056'), '237526-257056');
    });
  });
}
