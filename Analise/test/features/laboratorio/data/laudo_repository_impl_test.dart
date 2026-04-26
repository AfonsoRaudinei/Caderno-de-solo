import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/features/laboratorio/data/datasources/laudo_firestore_datasource.dart';
import 'package:soloforte/features/laboratorio/data/datasources/laudo_hive_datasource.dart';
import 'package:soloforte/features/laboratorio/data/models/laudo_recomendacao_model.dart';
import 'package:soloforte/features/laboratorio/data/repositories/laudo_repository_impl.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';

class MockLaudoHiveDatasource extends Mock implements LaudoHiveDatasource {}

class MockLaudoFirestoreDatasource extends Mock
    implements LaudoFirestoreDatasource {}

class FakeLaudoModel extends Fake implements LaudoRecomendacaoModel {}

LaudoRecomendacaoModel _model({
  required String id,
  required DateTime geradaEm,
}) {
  return LaudoRecomendacaoModel(
    id: id,
    userId: 'u1',
    analiseId: 'a1',
    calibracaoId: 'c1',
    geradaEm: geradaEm,
    talhao: 'Talhão $id',
    fazenda: 'Fazenda',
    cliente: 'Cliente',
    cultura: 'Soja',
    safra: '24/25',
    laboratorio: 'Lab',
    nomeCalibra: 'Cal 1',
    metodoCalagem: '① Saturação por Bases (V%)',
    doseCalcarioTHa: 1.2,
    vAtual: 45,
    vEsperado: 65,
    caAtual: 2,
    caEsperado: 2.5,
    mgAtual: 0.7,
    mgEsperado: 0.9,
    relacaoCaMg: 2.8,
    parcelamento: const [],
    gessoIndicado: false,
    gessoKgHa: 0,
    modoFosforo: '① Correção do solo',
    pSoloMgDm3: 10,
    ncFosforo: 20,
    doseP2O5KgHa: 35,
    legacyP: false,
    criterioPotassio: 'Ambos',
    kSolo: 0.2,
    ncPotassio: 70,
    doseK2OKgHa: 80,
    micros: const [],
    avisos: const [],
    argumentos: 'ok',
  );
}

LaudoRecomendacao _entity(String id) => LaudoRecomendacao(
      id: id,
      userId: 'u1',
      analiseId: 'a1',
      calibracaoId: 'c1',
      geradaEm: DateTime(2026, 3, 1),
      talhao: 'Talhão',
      fazenda: 'Fazenda',
      cliente: 'Cliente',
      cultura: 'Soja',
      safra: '24/25',
      laboratorio: 'Lab',
      nomeCalibra: 'Cal',
      metodoCalagem: '① Saturação por Bases (V%)',
      doseCalcarioTHa: 1.2,
      vAtual: 45,
      vEsperado: 65,
      caAtual: 2,
      caEsperado: 2.5,
      mgAtual: 0.7,
      mgEsperado: 0.9,
      relacaoCaMg: 2.8,
      parcelamento: const [],
      gessoIndicado: false,
      gessoKgHa: 0,
      modoFosforo: '① Correção do solo',
      pSoloMgDm3: 10,
      ncFosforo: 20,
      doseP2O5KgHa: 35,
      legacyP: false,
      criterioPotassio: 'Ambos',
      kSolo: 0.2,
      ncPotassio: 70,
      doseK2OKgHa: 80,
      micros: const [],
      avisos: const [],
      argumentos: 'ok',
    );

void main() {
  setUpAll(() {
    registerFallbackValue(FakeLaudoModel());
  });

  late MockLaudoHiveDatasource hive;
  late MockLaudoFirestoreDatasource firestore;
  late LaudoRepositoryImpl repository;

  setUp(() {
    hive = MockLaudoHiveDatasource();
    firestore = MockLaudoFirestoreDatasource();
    repository = LaudoRepositoryImpl(
      hiveDatasource: hive,
      firestoreDatasource: firestore,
    );
  });

  test('getLaudos faz merge remoto/local e ordena por data desc', () async {
    final localOld = _model(id: 'A', geradaEm: DateTime(2026, 1, 1));
    final remoteNewSameId = _model(id: 'A', geradaEm: DateTime(2026, 2, 1));
    final remoteNewest = _model(id: 'B', geradaEm: DateTime(2026, 3, 1));

    when(() => hive.getLaudos()).thenAnswer((_) async => [localOld]);
    when(() => firestore.getLaudos())
        .thenAnswer((_) async => [remoteNewSameId, remoteNewest]);
    when(() => hive.saveLaudo(any())).thenAnswer((_) async {});

    final result = await repository.getLaudos();

    expect(result.map((e) => e.id).toList(), ['B', 'A']);
    expect(result.first.geradaEm, DateTime(2026, 3, 1));
    expect(result.last.geradaEm, DateTime(2026, 2, 1));
    verify(() => hive.saveLaudo(any())).called(2);
  });

  test('getLaudos cai para Hive quando remoto falha', () async {
    final local = _model(id: 'L1', geradaEm: DateTime(2026, 1, 1));

    when(() => firestore.getLaudos()).thenThrow(Exception('offline'));
    when(() => hive.getLaudos()).thenAnswer((_) async => [local]);

    final result = await repository.getLaudos();

    expect(result.length, 1);
    expect(result.first.id, 'L1');
  });

  test('saveLaudo persiste local e sincroniza remoto', () async {
    when(() => hive.saveLaudo(any())).thenAnswer((_) async {});
    when(() => firestore.saveLaudo(any())).thenAnswer((_) async {});

    await repository.saveLaudo(_entity('SAVE-1'));

    verify(() => hive.saveLaudo(any())).called(1);
    verify(() => firestore.saveLaudo(any())).called(1);
  });

  test('deleteLaudo remove local e remoto', () async {
    when(() => hive.deleteLaudo('DEL-1')).thenAnswer((_) async {});
    when(() => firestore.deleteLaudo('DEL-1')).thenAnswer((_) async {});

    await repository.deleteLaudo('DEL-1');

    verify(() => hive.deleteLaudo('DEL-1')).called(1);
    verify(() => firestore.deleteLaudo('DEL-1')).called(1);
  });
}
