import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/features/historico/presentation/historico_page.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/laudo_repository.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart';

class FakeLaudoRepository implements LaudoRepository {
  FakeLaudoRepository({
    List<LaudoRecomendacao>? initial,
    this.failGet = false,
    this.delayGet,
  }) : _laudos = List<LaudoRecomendacao>.from(initial ?? const []);

  final List<LaudoRecomendacao> _laudos;
  final bool failGet;
  final Completer<void>? delayGet;
  final List<String> deletedIds = [];

  @override
  Future<List<LaudoRecomendacao>> getLaudos() async {
    if (delayGet != null) {
      await delayGet!.future;
    }
    if (failGet) {
      throw Exception('falha get');
    }
    return List<LaudoRecomendacao>.from(_laudos);
  }

  @override
  Future<void> saveLaudo(LaudoRecomendacao laudo) async {
    _laudos.removeWhere((e) => e.id == laudo.id);
    _laudos.insert(0, laudo);
  }

  @override
  Future<void> deleteLaudo(String id) async {
    deletedIds.add(id);
    _laudos.removeWhere((e) => e.id == id);
  }
}

LaudoRecomendacao _laudo({
  String id = 'L1',
  LaudoStatus status = LaudoStatus.completo,
}) {
  return LaudoRecomendacao(
    id: id,
    userId: 'u1',
    analiseId: 'a1',
    calibracaoId: 'c1',
    geradaEm: DateTime(2026, 4, 5, 10, 0),
    talhao: 'Talhão 01',
    fazenda: 'Fazenda Central',
    cliente: 'Cliente',
    cultura: 'Soja',
    safra: '24/25',
    laboratorio: 'Lab',
    nomeCalibra: 'Calibração A',
    metodoCalagem: '① Saturação por Bases (V%)',
    doseCalcarioTHa: 1.2,
    vAtual: 45,
    vEsperado: 65,
    caAtual: 2,
    caEsperado: 2.4,
    mgAtual: 0.8,
    mgEsperado: 1.0,
    relacaoCaMg: 2.5,
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
    status: status,
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeLaudoRepository repo,
) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HistoricoPage(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        laudoRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('exibe loading enquanto carrega', (tester) async {
    final completer = Completer<void>();
    final repo = FakeLaudoRepository(delayGet: completer);

    await _pumpPage(tester, repo);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
  });

  testWidgets('exibe estado vazio quando não há laudos', (tester) async {
    final repo = FakeLaudoRepository();

    await _pumpPage(tester, repo);
    await tester.pumpAndSettle();

    expect(find.text('Histórico vazio'), findsOneWidget);
    expect(find.text('Ir para Lab'), findsOneWidget);
  });

  testWidgets('exibe card de laudo quando há dados', (tester) async {
    final repo = FakeLaudoRepository(initial: [_laudo()]);

    await _pumpPage(tester, repo);
    await tester.pumpAndSettle();

    expect(find.text('Talhão 01'), findsOneWidget);
    expect(find.text('Completo'), findsOneWidget);
    expect(find.textContaining('Calcário'), findsOneWidget);
  });

  testWidgets('exibe estado de erro quando getLaudos falha', (tester) async {
    final repo = FakeLaudoRepository(failGet: true);

    await _pumpPage(tester, repo);
    await tester.pumpAndSettle();

    expect(find.textContaining('Erro ao carregar histórico'), findsOneWidget);
  });
}
