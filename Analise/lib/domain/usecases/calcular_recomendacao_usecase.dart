import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/calibracao_entity.dart';
import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';
import 'package:soloforte/domain/models/analise_model.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';

class CalcularRecomendacaoUseCase {
  /// Gera uma recomendação completa baseado em uma AnaliseModel
  /// Retorna um RecomendacaoModel novo (sem ID salvo no banco ainda)
  RecomendacaoModel call(
      {required AnaliseModel analise, required double prntDesejado}) {
    // 1 - Cálculo de Calcário (Método V%)
    // Considerando por padrão V% desejado de 70% para as culturas em geral
    final calcario = CalcarioFormula.metodoV(
      ctc: analise.ctc,
      vAtual: analise.saturacaoBases,
      vDesejado: 70.0,
      prnt: prntDesejado,
    );

    // 2 - Fósforo (Considerando solo argiloso para fins do exemplo > 35%)
    final pCritico = FosforoFormula.nivelCriticoMehlich1(40.0);
    final pDose = FosforoFormula.recomendacao(analise.fosforo, pCritico);

    // 3 - Potássio (Alvo de 5% de participação na CTC)
    final kDose = PotassioFormula.recomendacao(
      ctc: analise.ctc,
      kAtual: analise.potassio,
      participacaoDesejada: 5.0,
    );

    return RecomendacaoModel(
      id: '', // Será gerado pelo repository
      analiseId: analise.id,
      cultura: analise.cultura,
      necessidadeCalagem: calcario,
      prnt: prntDesejado,
      doseCalcario: calcario, // Simplificação
      p2o5: pDose,
      k2o: kDose,
      citacaoCalagem: CitacaoCalibracaoModel.calagem,
      citacaoGesso: CitacaoCalibracaoModel.gesso,
      citacaoFosforo: CitacaoCalibracaoModel.fosforo,
      citacaoPotassio: CitacaoCalibracaoModel.potassio,
      citacaoEnxofre: CitacaoCalibracaoModel.enxofre,
      citacaoMicronutrientes: CitacaoCalibracaoModel.micronutrientes,
    );
  }

  RecomendacaoModel fromEntities({
    required CalibracaoEntity calibracao,
    required AnaliseEntity analise,
  }) {
    final fonteP =
        calibracao.metodoPosforoSelecionado.toLowerCase().contains('mehlich')
            ? FonteP.mehlich
            : FonteP.resina;
    final model = AnaliseModel(
      id: analise.id,
      userId: 'local',
      fazendaNome: analise.fazenda,
      talhaoNome: analise.talhao,
      dataColeta: DateTime.now().toIso8601String(),
      status: 'Gerada',
      cultura: analise.cultura,
      ph: analise.ph,
      fosforo: FosforoData(
        pResina: analise.p,
        pMehlich: analise.p,
        fontePrincipal: fonteP,
      ),
      potassio: analise.k,
      calcio: analise.ca,
      magnesio: analise.mg,
      ctc: analise.ctc,
      saturacaoBases: analise.vPercent,
    );

    final prntDesejado = _inferirPrnt(calibracao);
    return call(
      analise: model,
      prntDesejado: prntDesejado,
    ).copyWith(
      analiseId: analise.id,
      cultura: analise.cultura,
    );
  }

  double _inferirPrnt(CalibracaoEntity calibracao) {
    if (calibracao.metodoCalagemSelecionado.toLowerCase().contains('smp')) {
      return 90.0;
    }
    if (calibracao.metodoCalagemSelecionado
            .toLowerCase()
            .contains('alumínio') ||
        calibracao.metodoCalagemSelecionado
            .toLowerCase()
            .contains('aluminio')) {
      return 85.0;
    }
    return 80.0;
  }
}
