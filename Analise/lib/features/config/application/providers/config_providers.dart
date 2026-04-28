import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/config/data/datasources/config_local_datasource.dart';
import 'package:soloforte/features/config/data/datasources/config_remote_datasource.dart';
import 'package:soloforte/features/config/data/repositories/config_repository_impl.dart';
import 'package:soloforte/features/config/domain/repositories/config_repository.dart';
import 'package:soloforte/features/config/domain/usecases/config_usecases.dart';

final configRemoteDatasourceProvider = Provider<ConfigRemoteDatasource>((ref) {
  return ConfigRemoteDatasource();
});

final configLocalDatasourceProvider = Provider<ConfigLocalDatasource>((ref) {
  return ConfigLocalDatasource();
});

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(
    remoteDatasource: ref.watch(configRemoteDatasourceProvider),
    localDatasource: ref.watch(configLocalDatasourceProvider),
    authDatasource: ref.watch(authDatasourceProvider),
  );
});

final getUserProfileUsecaseProvider = Provider<GetUserProfileUsecase>((ref) {
  return GetUserProfileUsecase(ref.watch(configRepositoryProvider));
});

final updateProfileFieldUsecaseProvider =
    Provider<UpdateProfileFieldUsecase>((ref) {
  return UpdateProfileFieldUsecase(ref.watch(configRepositoryProvider));
});

final logoutConfigUsecaseProvider = Provider<LogoutConfigUsecase>((ref) {
  return LogoutConfigUsecase(ref.watch(configRepositoryProvider));
});

final excluirContaUsecaseProvider = Provider<ExcluirContaUsecase>((ref) {
  return ExcluirContaUsecase(ref.watch(configRepositoryProvider));
});

final limparDadosLocaisUsecaseProvider =
    Provider<LimparDadosLocaisUsecase>((ref) {
  return LimparDadosLocaisUsecase(ref.watch(configRepositoryProvider));
});

final getPerfilAssetsUsecaseProvider = Provider<GetPerfilAssetsUsecase>((ref) {
  return GetPerfilAssetsUsecase(ref.watch(configRepositoryProvider));
});

final uploadLogoUsecaseProvider = Provider<UploadLogoUsecase>((ref) {
  return UploadLogoUsecase(ref.watch(configRepositoryProvider));
});

final uploadAssinaturaUsecaseProvider =
    Provider<UploadAssinaturaUsecase>((ref) {
  return UploadAssinaturaUsecase(ref.watch(configRepositoryProvider));
});

final removeLogoUsecaseProvider = Provider<RemoveLogoUsecase>((ref) {
  return RemoveLogoUsecase(ref.watch(configRepositoryProvider));
});

final removeAssinaturaUsecaseProvider =
    Provider<RemoveAssinaturaUsecase>((ref) {
  return RemoveAssinaturaUsecase(ref.watch(configRepositoryProvider));
});
