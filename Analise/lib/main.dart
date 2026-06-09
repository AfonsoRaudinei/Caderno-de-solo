import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/core/router/app_router.dart';
import 'package:soloforte/core/services/app_observability.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/features/config/application/providers/app_theme_mode_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soloforte/firebase_options.dart';
import 'package:soloforte/core/constants/default_lab_templates.dart';
import 'package:soloforte/data/datasources/lab_template_datasource.dart';
import 'package:soloforte/domain/models/lab_template_model.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Hive.initFlutter();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await _activateFirebaseAppCheck();
      await AppObservability.instance.initialize();
      AppObservability.instance.installGlobalHandlers();

      await _initDefaultLabTemplates();

      runApp(
        const ProviderScope(
          child: AnaliseApp(),
        ),
      );
    },
    (error, stack) {
      unawaited(
        AppObservability.instance.recordError(
          error,
          stack,
          fatal: true,
          reason: 'run_zoned_guarded',
        ),
      );
    },
  );
}

/// Inicializa os templates de laboratório padrão no Hive.
/// Insere cada template padrão que ainda não existe (upsert por ID),
/// garantindo que novos labs adicionados em updates sejam persistidos.
Future<void> _initDefaultLabTemplates() async {
  final datasource = LabTemplateDatasource();
  for (final template in defaultLabTemplates) {
    final existing = await datasource.getById(template.id);
    if (existing == null) {
      final model = LabTemplateModel.fromEntity(template);
      await datasource.save(model);
    }
  }
}

Future<void> _activateFirebaseAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    providerAndroid: AppConfig.isRelease
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
    providerApple: AppConfig.isRelease
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(),
  );
}

class AnaliseApp extends HookConsumerWidget {
  const AnaliseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeModeProvider).valueOrNull;

    return MaterialApp.router(
      title: 'Analise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.black,
      themeMode: themeMode?.materialThemeMode ?? ThemeMode.system,
      locale: const Locale('pt', 'BR'),
      routerConfig: router,
    );
  }
}
