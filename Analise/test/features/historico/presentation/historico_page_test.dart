import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/historico/presentation/historico_page.dart';
import 'package:soloforte/features/historico/presentation/historico_provider.dart';

class _FakeHistoricoNotifier extends HistoricoNotifier {
  _FakeHistoricoNotifier({
    required this.items,
    this.fail = false,
    this.delay,
  });

  final List<RecomendacaoModel> items;
  final bool fail;
  final Completer<void>? delay;

  @override
  Future<List<RecomendacaoModel>> build() async {
    if (delay != null) {
      await delay!.future;
    }
    if (fail) {
      throw Exception('falha get');
    }
    return items;
  }
}

RecomendacaoModel _recomendacao({
  String id = 'R1',
  DateTime? createdAt,
}) {
  return RecomendacaoModel(
    id: id,
    analiseId: 'a1',
    cultura: 'Soja',
    necessidadeCalagem: 1.2,
    prnt: 80,
    doseCalcario: 1.2,
    p2o5: 35,
    k2o: 80,
    createdAt: createdAt ?? DateTime(2026, 4, 5, 10, 0),
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  List<RecomendacaoModel> items = const [],
  bool fail = false,
  Completer<void>? delay,
}) async {
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
        historicoProvider.overrideWith(
          () => _FakeHistoricoNotifier(
            items: items,
            fail: fail,
            delay: delay,
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  testWidgets('exibe loading enquanto carrega', (tester) async {
    final completer = Completer<void>();

    await _pumpPage(tester, delay: completer);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
  });

  testWidgets('exibe estado vazio quando não há recomendações', (tester) async {
    await _pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma recomendação salva ainda'), findsOneWidget);
    expect(find.text('Gere uma recomendação na aba Lab'), findsOneWidget);
  });

  testWidgets('exibe card de recomendação quando há dados', (tester) async {
    await _pumpPage(tester, items: [_recomendacao()]);
    await tester.pumpAndSettle();

    expect(find.text('Talhão não informado'), findsOneWidget);
    expect(find.text('Completo'), findsOneWidget);
    expect(find.textContaining('Calcário'), findsWidgets);
  });

  testWidgets('exibe estado de erro quando histórico falha', (tester) async {
    await _pumpPage(tester, fail: true);
    await tester.pumpAndSettle();

    expect(find.textContaining('Erro ao carregar histórico'), findsOneWidget);
  });
}
