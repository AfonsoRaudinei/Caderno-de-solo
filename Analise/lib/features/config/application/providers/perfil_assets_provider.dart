import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/application/providers/config_providers.dart';
import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';

export 'package:soloforte/features/config/domain/entities/perfil_assets.dart';

class PerfilAssetsNotifier extends StateNotifier<PerfilAssets> {
  PerfilAssetsNotifier(this._ref) : super(const PerfilAssets()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = await _ref.read(getPerfilAssetsUsecaseProvider).call();
  }

  Future<bool> uploadLogo() async {
    state = state.copyWith(isUploadingLogo: true);
    try {
      final url = await _ref.read(uploadLogoUsecaseProvider).call();
      if (url == null) return false;
      state = state.copyWith(logoUrl: url);
      return true;
    } finally {
      state = state.copyWith(isUploadingLogo: false);
    }
  }

  Future<bool> uploadAssinatura() async {
    state = state.copyWith(isUploadingAssinatura: true);
    try {
      final url = await _ref.read(uploadAssinaturaUsecaseProvider).call();
      if (url == null) return false;
      state = state.copyWith(assinaturaUrl: url);
      return true;
    } finally {
      state = state.copyWith(isUploadingAssinatura: false);
    }
  }

  Future<bool> removeLogo() async {
    await _ref.read(removeLogoUsecaseProvider).call();
    state = PerfilAssets(
      logoUrl: null,
      assinaturaUrl: state.assinaturaUrl,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
    return true;
  }

  Future<bool> removeAssinatura() async {
    await _ref.read(removeAssinaturaUsecaseProvider).call();
    state = PerfilAssets(
      logoUrl: state.logoUrl,
      assinaturaUrl: null,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
    return true;
  }
}

final perfilAssetsProvider =
    StateNotifierProvider<PerfilAssetsNotifier, PerfilAssets>(
  (ref) => PerfilAssetsNotifier(ref),
);
