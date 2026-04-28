import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';
import 'package:soloforte/domain/usecases/get_current_user_id_usecase.dart';

final getCurrentUserIdUsecaseProvider =
    Provider<GetCurrentUserIdUsecase>((ref) {
  return GetCurrentUserIdUsecase(ref.watch(authRepositoryProvider));
});

final waitForCurrentUserIdUsecaseProvider =
    Provider<WaitForCurrentUserIdUsecase>((ref) {
  return WaitForCurrentUserIdUsecase(ref.watch(authRepositoryProvider));
});
