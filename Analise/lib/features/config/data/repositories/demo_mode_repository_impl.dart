import 'package:soloforte/features/config/data/datasources/demo_mode_hive_datasource.dart';
import 'package:soloforte/features/config/domain/repositories/demo_mode_repository.dart';

class DemoModeRepositoryImpl implements DemoModeRepository {
  const DemoModeRepositoryImpl(this._datasource);

  final DemoModeHiveDatasource _datasource;

  @override
  Future<bool> isEnabled() => _datasource.isEnabled();

  @override
  Future<void> setEnabled(bool value) => _datasource.setEnabled(value);
}
