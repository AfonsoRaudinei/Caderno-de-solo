import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/models/analise_draft.dart';

void main() {
  const engine = AnaliseValidationEngine();

  AnaliseDraft baseDraft({
    String talhao = 'T-01',
    String profundidade = '0-20',
    String phCaCl2 = '5.4',
    String k = '0.31',
    String ca = '3.1',
    String mg = '1.2',
    String pResina = '18',
  }) {
    return AnaliseDraft(
      fields: {
        'talhao': talhao,
        'profundidade': profundidade,
        'phCaCl2': phCaCl2,
        'k': k,
        'ca': ca,
        'mg': mg,
        'pResina': pResina,
      },
    );
  }

  group('AnaliseValidationEngine', () {
    test('normaliza K de Exata Brasil (mg/dm3 -> cmolc/dm3)', () {
      final snapshot = engine.validate(
        drafts: [baseDraft(k: '391', pResina: '')],
        labDisplayName: 'Exata Brasil',
      );

      expect(snapshot.hasBlockingErrors, isFalse);
      expect(snapshot.normalizedColumns.first['k'], '1');
      expect(
        snapshot.issues.any((i) => i.code == 'WARN_CONVERT_K_MGDM3'),
        isTrue,
      );
    });

    test('aplica obrigatoriedade por laboratório (IBRA exige P Resina)', () {
      final snapshot = engine.validate(
        drafts: [baseDraft(pResina: '')],
        labDisplayName: 'IBRA',
      );

      expect(snapshot.hasBlockingErrors, isFalse);
      expect(snapshot.hasWarnings, isTrue);
      final issue = snapshot.issues.firstWhere((i) => i.fieldKey == 'pResina');
      expect(issue.code, 'ERR_REQUIRED_FIELD');
      expect(issue.columnLabel, 'A1');
    });

    test('gera erro de identidade quando Talhão e Nº Amostra estão vazios', () {
      final snapshot = engine.validate(
        drafts: [baseDraft(talhao: '')],
        labDisplayName: 'Sellar',
      );

      expect(snapshot.hasBlockingErrors, isFalse);
      expect(snapshot.hasWarnings, isTrue);
      expect(
        snapshot.issues.any((i) => i.code == 'ERR_IDENTITY_REQUIRED'),
        isTrue,
      );
    });

    test('marca campo não suportado no MB e remove valor normalizado', () {
      final snapshot = engine.validate(
        drafts: [
          baseDraft().copyWith(
            fields: {
              ...baseDraft().fields,
              'phAgua': '5.8',
            },
          ),
        ],
        labDisplayName: 'MB Agronegócios',
      );

      final warn = snapshot.issues.firstWhere((i) => i.fieldKey == 'phAgua');
      expect(warn.code, 'WARN_UNSUPPORTED_FIELD');
      expect(snapshot.normalizedColumns.first['phAgua'], '');
    });
  });
}
