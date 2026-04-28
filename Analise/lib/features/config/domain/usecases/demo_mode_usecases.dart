import 'package:soloforte/features/config/domain/repositories/demo_mode_repository.dart';

class GetDemoModeUsecase {
  const GetDemoModeUsecase(this._repository);

  final DemoModeRepository _repository;

  Future<bool> call() => _repository.isEnabled();
}

class SetDemoModeUsecase {
  const SetDemoModeUsecase(this._repository);

  final DemoModeRepository _repository;

  Future<void> call(bool value) => _repository.setEnabled(value);
}
