import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/router/app_router.dart';
import 'package:soloforte/main.dart';

void main() {
  testWidgets('AnaliseApp usa router e configurações base', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('ROOT_OK')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
        ],
        child: const AnaliseApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ROOT_OK'), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
    expect(materialApp.title, 'Analise');
    expect(materialApp.locale, const Locale('pt', 'BR'));
  });
}
