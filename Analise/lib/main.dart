import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/core/router/app_router.dart';
import 'package:soloforte/core/services/app_observability.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soloforte/firebase_options.dart';

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

    return MaterialApp.router(
      title: 'Analise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      routerConfig: router,
    );
  }
}
