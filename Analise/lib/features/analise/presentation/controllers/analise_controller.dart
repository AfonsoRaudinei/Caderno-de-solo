import 'package:soloforte/domain/models/location_data_model.dart';
import 'package:soloforte/domain/services/location_service.dart';
import 'package:soloforte/features/analise/presentation/providers/location_provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analise_controller.g.dart';

@riverpod
class AnaliseFormController extends _$AnaliseFormController {
  @override
  Map<String, dynamic> build() {
    return {
      'P': 0.0,
      'K': 0.0,
      'Ca': 0.0,
      'Mg': 0.0,
      'Al': 0.0,
      'HAl': 0.0,
      'ctc': 0.0,
      'v': 0.0,
      'is_loading_location': false,
      'location_data': null,
    };
  }

  void updateValue(String key, String valueStr) {
    if (valueStr.isEmpty) {
      valueStr = '0.0';
    }
    final rawVal = valueStr.replaceAll(',', '.'); // Aceita vírgula ou ponto
    final val = double.tryParse(rawVal) ?? 0.0;

    final newState = Map<String, dynamic>.from(state);
    newState[key] = val;

    // Recalcula CTC (T) = Ca + Mg + K + HAl
    // Recalcula V% = ((Ca + Mg + K) / CTC) * 100
    final ca = newState['Ca'] as double? ?? 0.0;
    final mg = newState['Mg'] as double? ?? 0.0;
    final k = newState['K'] as double? ?? 0.0;
    final hAl = newState['HAl'] as double? ?? 0.0;

    final sumBases = ca + mg + k;
    final ctc = sumBases + hAl;

    newState['ctc'] = ctc;

    if (ctc > 0) {
      newState['v'] = (sumBases / ctc) * 100;
    } else {
      newState['v'] = 0.0;
    }

    state = newState;
  }

  Future<void> captureLocation() async {
    state = {...state, 'is_loading_location': true};

    final service = ref.read(locationServiceProvider);
    try {
      final location = await service.capturar();
      state = {
        ...state,
        'is_loading_location': false,
        'location_data': LocationDataModel(
          latitude: location.latitude,
          longitude: location.longitude,
          accuracy: location.accuracy ?? 0,
          municipio: location.cidade,
          estado: location.estado,
          descricao: location.enderecoResumido,
        ),
      };
    } on LocationException {
      state = {
        ...state,
        'is_loading_location': false,
      };
    }
  }
}
