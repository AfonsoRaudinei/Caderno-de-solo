import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/router/app_router.dart';
import 'package:soloforte/data/datasources/lab_template_datasource.dart';
import 'package:soloforte/features/config/application/providers/app_theme_mode_provider.dart';
import 'package:soloforte/features/config/domain/entities/app_theme_mode.dart';
import 'package:soloforte/main.dart';

class _FixedThemeModeNotifier extends AppThemeModeNotifier {
  _FixedThemeModeNotifier(this._mode);

  final AppThemeMode _mode;

  @override
  Future<AppThemeMode> build() async => _mode;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init(Directory.systemTemp.createTempSync().path);
  });

  test('initDefaultLabTemplates persiste templates padrão ausentes', () async {
    await initDefaultLabTemplatesForTesting();

    final datasource = LabTemplateDatasource();
    expect(await datasource.count(), greaterThan(0));
  });

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
    expect(materialApp.routerConfig, isNotNull);
    expect(materialApp.locale, const Locale('pt', 'BR'));
  });

  testWidgets('AnaliseApp aplica tema escuro quando provider retorna black',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('THEME_OK')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          appThemeModeProvider.overrideWith(
            () => _FixedThemeModeNotifier(AppThemeMode.black),
          ),
        ],
        child: const AnaliseApp(),
      ),
    );

    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  testWidgets('AnaliseApp aplica tema claro quando provider retorna light',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('LIGHT_OK')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          appThemeModeProvider.overrideWith(
            () => _FixedThemeModeNotifier(AppThemeMode.light),
          ),
        ],
        child: const AnaliseApp(),
      ),
    );

    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
  });
}
