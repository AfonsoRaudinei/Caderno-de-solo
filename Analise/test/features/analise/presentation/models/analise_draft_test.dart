import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/models/analise_draft.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('AnaliseDraft', () {
    test('preserva id e dataCadastro ao converter para entidade', () {
      final data = DateTime(2025, 1, 10, 8, 30);
      final draft = AnaliseDraft(
        persistedId: 'analise-123',
        persistedDataCadastro: data,
        fields: const {
          'talhao': 'T-01',
          'numeroAmostra': 'A-001',
          'cultura': 'Soja',
          'profundidade': '0-20',
        },
      );

      final entity = draft.toEntity(
        uuid: const Uuid(),
        laudoProdutor: 'Produtor Teste',
        laudoFazenda: 'Fazenda Teste',
        laudoLaboratorio: 'IBRA',
        laudoSafra: '2025/2026',
      );

      expect(entity.id, 'analise-123');
      expect(entity.dataCadastro, data);
      expect(entity.talhao, 'T-01');
      expect(entity.numeroAmostra, 'A-001');
    });

    test('converte números com vírgula para double', () {
      const draft = AnaliseDraft(
        fields: {
          'k': '0,37',
          'ca': '2,50',
          'cultura': 'Soja',
        },
      );

      final entity = draft.toEntity(
        uuid: const Uuid(),
        laudoProdutor: 'P',
        laudoFazenda: 'F',
        laudoLaboratorio: 'L',
        laudoSafra: '2025/2026',
      );

      expect(entity.k, closeTo(0.37, 0.0001));
      expect(entity.ca, closeTo(2.50, 0.0001));
    });

    test('fallback de cultura para soja quando inválida', () {
      const draft = AnaliseDraft(
        fields: {
          'cultura': 'INEXISTENTE',
        },
      );

      final entity = draft.toEntity(
        uuid: const Uuid(),
        laudoProdutor: 'P',
        laudoFazenda: 'F',
        laudoLaboratorio: 'L',
        laudoSafra: '2025/2026',
      );

      expect(entity.cultura, Cultura.soja);
    });
  });
}
