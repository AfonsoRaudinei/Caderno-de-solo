import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';

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
      await ref
          .read(authRepositoryProvider)
          .enviarEmailRedefinicaoSenha(email.trim());

      // Sucesso -> marca state como enviado na view
      ref.read(linkEnviadoProvider.notifier).state = true;
      state = const AsyncData(null);
    } catch (e, stack) {
      final message = e is String && e.trim().isNotEmpty
          ? e
          : 'Erro ao enviar e-mail. Tente novamente.';
      state = AsyncError(message, stack);
    }
  }
}
