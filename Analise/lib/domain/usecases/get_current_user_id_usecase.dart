import 'package:soloforte/domain/repositories/auth_repository.dart';

class GetCurrentUserIdUsecase {
  const GetCurrentUserIdUsecase(this._repository);

  final AuthRepository _repository;

  String? call() => _repository.currentUserId();
}

class WaitForCurrentUserIdUsecase {
  const WaitForCurrentUserIdUsecase(this._repository);

  final AuthRepository _repository;

  Future<String?> call({Duration timeout = const Duration(seconds: 5)}) {
    return _repository.waitForCurrentUserId(timeout: timeout);
  }
}
