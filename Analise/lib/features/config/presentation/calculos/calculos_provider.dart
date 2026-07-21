import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/presentation/calculos/analise_normalizada.dart';
import 'package:soloforte/features/config/presentation/calculos/calculos_normalizador.dart';

final calculosSelectedAnaliseIdsProvider =
    StateProvider<List<String>>((ref) => const <String>[]);

class CalculosState {
  const CalculosState({
    this.analises = const <AnaliseNormalizada>[],
    this.media,
    this.isLoading = false,
    this.erro,
  });

  final List<AnaliseNormalizada> analises;
  final AnaliseNormalizada? media;
  final bool isLoading;
  final String? erro;

  CalculosState copyWith({
    List<AnaliseNormalizada>? analises,
    AnaliseNormalizada? media,
    bool? isLoading,
    String? erro,
    bool clearErro = false,
  }) {
    return CalculosState(
      analises: analises ?? this.analises,
      media: media ?? this.media,
      isLoading: isLoading ?? this.isLoading,
      erro: clearErro ? null : erro ?? this.erro,
    );
  }
}

class CalculosNotifier extends StateNotifier<CalculosState> {
  CalculosNotifier(this._ref) : super(const CalculosState());

  final Ref _ref;
  final CalculosNormalizador _normalizador = const CalculosNormalizador();

  Future<void> carregarAnalises(List<String> ids) async {
    if (ids.isEmpty) {
      state = const CalculosState();
      return;
    }

    state = state.copyWith(isLoading: true, clearErro: true);

    try {
      final normalizadas = await _buscarEConverter(ids);

      state = state.copyWith(
        analises: normalizadas,
        media: _normalizador.calcularMedia(normalizadas),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao carregar análises: $e',
      );
    }
  }

  Future<List<AnaliseNormalizada>> _buscarEConverter(List<String> ids) async {
    final repository = _ref.read(analiseRepositoryProvider);
    final todas = await repository.getAnalises();
    final byId = <String, AnaliseSolo>{
      for (final analise in todas) analise.id: analise,
    };
    final selecionadas = ids
        .map((id) => byId[id])
        .whereType<AnaliseSolo>()
        .toList(growable: false);

    return [
      for (var i = 0; i < selecionadas.length; i++)
        _normalizador.normalizar(
          selecionadas[i],
          label: 'Amostra ${i + 1}',
          index: i + 1,
        ),
    ];
  }
}

final calculosProvider = StateNotifierProvider<CalculosNotifier, CalculosState>(
  (ref) => CalculosNotifier(ref),
);
