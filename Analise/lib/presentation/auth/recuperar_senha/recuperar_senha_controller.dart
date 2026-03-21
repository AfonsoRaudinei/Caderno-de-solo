import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recuperar_senha_controller.g.dart';

final linkEnviadoProvider = StateProvider.autoDispose<bool>((ref) => false);

@riverpod
class RecuperarSenhaController extends _$RecuperarSenhaController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> enviarLink(String email) async {
    state = const AsyncLoading();

    try {
      // Mock rede
      await Future.delayed(const Duration(seconds: 2));

      // Sucesso -> marca state como enviado na view
      ref.read(linkEnviadoProvider.notifier).state = true;
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Erro ao enviar o link de recuperação.', stack);
    }
  }
}
