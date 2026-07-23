import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';
import 'package:soloforte/domain/usecases/calcular_fosforo_calculos_usecase.dart';
import 'package:soloforte/domain/usecases/calcular_gesso_calculos_usecase.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_controller.dart';
import 'package:soloforte/features/config/presentation/calculos/analise_normalizada.dart';
import 'package:soloforte/features/config/presentation/calculos/calculos_normalizador.dart';

final calculosSelectedAnaliseIdsProvider =
    StateProvider<List<String>>((ref) => const <String>[]);
final calculosSelectedCalibracaoIdProvider =
    StateProvider<String?>((ref) => null);

class CalculosState {
  const CalculosState({
    this.analises = const <AnaliseNormalizada>[],
    this.media,
    this.calibracao,
    this.resultadoCalagem,
    this.resultadoGesso,
    this.resultadoFosforo,
    this.isLoading = false,
    this.erro,
  });

  final List<AnaliseNormalizada> analises;
  final AnaliseNormalizada? media;
  final CalibracaoProfile? calibracao;
  final CalculoCalagemResultado? resultadoCalagem;
  final CalculoGessoResultado? resultadoGesso;
  final CalculoFosforoResultado? resultadoFosforo;
  final bool isLoading;
  final String? erro;

  CalculosState copyWith({
    List<AnaliseNormalizada>? analises,
    AnaliseNormalizada? media,
    CalibracaoProfile? calibracao,
    CalculoCalagemResultado? resultadoCalagem,
    CalculoGessoResultado? resultadoGesso,
    CalculoFosforoResultado? resultadoFosforo,
    bool? isLoading,
    String? erro,
    bool clearCalibracao = false,
    bool clearResultadoCalagem = false,
    bool clearResultadoGesso = false,
    bool clearResultadoFosforo = false,
    bool clearErro = false,
  }) {
    return CalculosState(
      analises: analises ?? this.analises,
      media: media ?? this.media,
      calibracao: clearCalibracao ? null : calibracao ?? this.calibracao,
      resultadoCalagem: clearResultadoCalagem
          ? null
          : resultadoCalagem ?? this.resultadoCalagem,
      resultadoGesso:
          clearResultadoGesso ? null : resultadoGesso ?? this.resultadoGesso,
      resultadoFosforo: clearResultadoFosforo
          ? null
          : resultadoFosforo ?? this.resultadoFosforo,
      isLoading: isLoading ?? this.isLoading,
      erro: clearErro ? null : erro ?? this.erro,
    );
  }
}

class CalculosNotifier extends StateNotifier<CalculosState> {
  CalculosNotifier(this._ref) : super(const CalculosState());

  final Ref _ref;
  final CalculosNormalizador _normalizador = const CalculosNormalizador();
  final CalcularCalagemCalculosUsecase _calcularCalagem =
      const CalcularCalagemCalculosUsecase();
  final CalcularGessoCalculosUsecase _calcularGesso =
      const CalcularGessoCalculosUsecase();
  final CalcularFosforoCalculosUsecase _calcularFosforo =
      const CalcularFosforoCalculosUsecase();

  Future<void> carregarDados(List<String> ids, String? calibracaoId) async {
    if (ids.isEmpty) {
      state = const CalculosState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearErro: true,
      clearCalibracao: calibracaoId == null,
      clearResultadoCalagem: true,
      clearResultadoGesso: true,
      clearResultadoFosforo: true,
    );

    try {
      final normalizadas = await _buscarEConverter(ids);
      final media = _normalizador.calcularMedia(normalizadas);
      final calibracao = _buscarCalibracao(calibracaoId);
      final resultadoCalagem =
          calibracao == null ? null : _calcularCalagemMedia(media, calibracao);
      final resultadoGesso =
          calibracao == null ? null : _calcularGessoMedia(media, calibracao);
      final resultadoFosforo =
          calibracao == null ? null : _calcularFosforoMedia(media, calibracao);

      state = state.copyWith(
        analises: normalizadas,
        media: media,
        calibracao: calibracao,
        resultadoCalagem: resultadoCalagem,
        resultadoGesso: resultadoGesso,
        resultadoFosforo: resultadoFosforo,
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

  CalibracaoProfile? _buscarCalibracao(String? id) {
    if (id == null || id.isEmpty) return null;
    final profiles = _ref.read(calibracaoControllerProvider).profiles;
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  CalculoCalagemResultado _calcularCalagemMedia(
    AnaliseNormalizada media,
    CalibracaoProfile calibracao,
  ) {
    return _calcularCalagem(
      analise: CalculoCalagemAnaliseInput(
        id: media.id,
        label: media.label,
        talhao: media.talhao,
        laboratorio: media.laboratorio,
        phCaCl2: media.phCaCl2,
        materiaOrganica: media.materiaOrganica,
        ca: media.ca,
        mg: media.mg,
        k: media.k,
        hAl: media.hAl,
        al: media.al,
        ctc: media.ctc,
        vPercent: media.vPercent,
        p: _pParaCalculo(media, calibracao),
        argila: media.argila,
        pRem: media.pRem,
      ),
      calibracao: calibracao,
    );
  }

  CalculoGessoResultado _calcularGessoMedia(
    AnaliseNormalizada media,
    CalibracaoProfile calibracao,
  ) {
    return _calcularGesso(
      analise: CalculoCalagemAnaliseInput(
        id: media.id,
        label: media.label,
        talhao: media.talhao,
        laboratorio: media.laboratorio,
        phCaCl2: media.phCaCl2,
        materiaOrganica: media.materiaOrganica,
        ca: media.ca,
        mg: media.mg,
        k: media.k,
        hAl: media.hAl,
        al: media.al,
        ctc: media.ctc,
        vPercent: media.vPercent,
        p: _pParaCalculo(media, calibracao),
        argila: media.argila,
        pRem: media.pRem,
      ),
      calibracao: calibracao,
    );
  }

  CalculoFosforoResultado _calcularFosforoMedia(
    AnaliseNormalizada media,
    CalibracaoProfile calibracao,
  ) {
    return _calcularFosforo(
      analise: CalculoCalagemAnaliseInput(
        id: media.id,
        label: media.label,
        talhao: media.talhao,
        laboratorio: media.laboratorio,
        phCaCl2: media.phCaCl2,
        materiaOrganica: media.materiaOrganica,
        ca: media.ca,
        mg: media.mg,
        k: media.k,
        hAl: media.hAl,
        al: media.al,
        ctc: media.ctc,
        vPercent: media.vPercent,
        p: _pParaCalculo(media, calibracao),
        argila: media.argila,
        pRem: media.pRem,
      ),
      calibracao: calibracao,
    );
  }

  double? _pParaCalculo(
    AnaliseNormalizada media,
    CalibracaoProfile calibracao,
  ) {
    final fosforo = calibracao.parametrosCards['fosforo'];
    final referencia =
        fosforo is Map ? fosforo['referencia']?.toString() ?? '' : '';
    if (referencia == 'IAC Bol.100') {
      return media.pResina ?? media.pMehlich;
    }
    return media.pMehlich ?? media.pResina;
  }
}

final calculosProvider = StateNotifierProvider<CalculosNotifier, CalculosState>(
  (ref) => CalculosNotifier(ref),
);
