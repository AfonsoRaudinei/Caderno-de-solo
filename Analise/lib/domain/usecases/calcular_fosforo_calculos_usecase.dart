import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';
import 'package:soloforte/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart';

class CalculoFosforoResultado {
  const CalculoFosforoResultado({
    required this.modo,
    required this.referencia,
    required this.nc,
    required this.pAtual,
    required this.fep,
    required this.percentualUsoSolo,
    required this.doseTotalP2O5KgHa,
    required this.doseCorrecaoP2O5KgHa,
    required this.doseExportacaoP2O5KgHa,
    required this.doseExtracaoP2O5KgHa,
    required this.pSoloCreditadoP2O5KgHa,
    required this.resumoCalculo,
    required this.tipoFonteAbsorcao,
    required this.fonteAbsorcao,
    required this.tipoDadoAbsorcao,
    required this.produtividadeEsperadaTha,
    required this.referenciaAbsorcaoKgPorT,
    required this.qualidadeReferenciaAbsorcao,
  });

  final String modo;
  final String referencia;
  final double nc;
  final double pAtual;
  final double fep;
  final double percentualUsoSolo;
  final double doseTotalP2O5KgHa;
  final double doseCorrecaoP2O5KgHa;
  final double doseExportacaoP2O5KgHa;
  final double doseExtracaoP2O5KgHa;
  final double pSoloCreditadoP2O5KgHa;
  final String resumoCalculo;
  final String tipoFonteAbsorcao;
  final String fonteAbsorcao;
  final String tipoDadoAbsorcao;
  final double? produtividadeEsperadaTha;
  final double? referenciaAbsorcaoKgPorT;
  final String qualidadeReferenciaAbsorcao;
}

class CalcularFosforoCalculosUsecase {
  const CalcularFosforoCalculosUsecase();

  CalculoFosforoResultado call({
    required CalculoCalagemAnaliseInput analise,
    required CalibracaoProfile calibracao,
  }) {
    final fosforo = _asMap(calibracao.parametrosCards['fosforo']);
    final referencia = _asString(fosforo['referencia'], 'IAC Bol.100');
    final pAtual = _required(analise.p, 'P atual');
    final argila = _required(analise.argila, 'argila');
    final nc = _asNum(
      fosforo['nc'],
      referencia == 'IAC Bol.100'
          ? FosforoFormula.nivelCriticoResina(argila)
          : FosforoFormula.nivelCriticoMehlich1(argila),
    );
    final fep = _asNum(fosforo['fepBase'], FosforoFormula.fepBase(argila));
    final corrigirSolo = _corrigirSolo(fosforo);
    final reposicao = _reposicao(fosforo);
    final percentualUsoSolo = reposicao == ReposicaoFosforo.extracao
        ? _asNum(fosforo['percentualUsoPSolo'], 100.0)
        : 0.0;
    final tipoFonteAbsorcao = _asString(fosforo['fosforoTipoFonte'], 'Autores');
    final fonteAbsorcao = _fonteAbsorcao(fosforo, tipoFonteAbsorcao);
    final tipoDadoAbsorcao = reposicao == ReposicaoFosforo.exportacao
        ? 'Exportação'
        : reposicao == ReposicaoFosforo.extracao
            ? 'Extração'
            : 'Nenhum';
    final absorcaoSelecionada = tipoDadoAbsorcao == 'Nenhum'
        ? null
        : _absorcaoP(
            tipoFonte: tipoFonteAbsorcao,
            fonteNome: fonteAbsorcao,
            tipoDado: tipoDadoAbsorcao,
          );
    final exportacaoP2O5 = _p2O5PorAbsorcao(
          tipoFonte: tipoFonteAbsorcao,
          fonteNome: fonteAbsorcao,
          tipoDado: 'Exportação',
          produtividadeEsperadaTha: calibracao.produtividadeEsperadaTha,
        ) ??
        _exportacaoP2O5(calibracao.cultura);
    final extracaoP2O5 = _p2O5PorAbsorcao(
          tipoFonte: tipoFonteAbsorcao,
          fonteNome: fonteAbsorcao,
          tipoDado: 'Extração',
          produtividadeEsperadaTha: calibracao.produtividadeEsperadaTha,
        ) ??
        _extracaoP2O5(calibracao.cultura);

    final resultado = FosforoFormula.recomendacaoComponentes(
      corrigirSolo: corrigirSolo,
      reposicao: reposicao,
      correcaoInput: FosforoInput(
        argila: argila,
        pAtual: pAtual,
        nc: nc,
        referencia: referencia,
      ),
      pSolo: pAtual,
      percentualUsoSoloExtracao: percentualUsoSolo,
      profundidadeCm: 20,
      exportacaoP2O5: exportacaoP2O5,
      extracaoP2O5: extracaoP2O5,
      fepFinal: fep,
    );

    return CalculoFosforoResultado(
      modo: resultado.modoResumo,
      referencia: referencia,
      nc: nc,
      pAtual: pAtual,
      fep: fep,
      percentualUsoSolo: percentualUsoSolo,
      doseTotalP2O5KgHa: resultado.doseTotal,
      doseCorrecaoP2O5KgHa: resultado.doseCorrecao,
      doseExportacaoP2O5KgHa: resultado.doseExportacao,
      doseExtracaoP2O5KgHa: resultado.doseExtracao,
      pSoloCreditadoP2O5KgHa: resultado.pSoloCreditadoP2O5,
      resumoCalculo: _resumo(
        modo: resultado.modoResumo,
        pAtual: pAtual,
        nc: nc,
        fep: fep,
        percentualUsoSolo: percentualUsoSolo,
      ),
      tipoFonteAbsorcao: tipoFonteAbsorcao,
      fonteAbsorcao: fonteAbsorcao,
      tipoDadoAbsorcao: tipoDadoAbsorcao,
      produtividadeEsperadaTha: calibracao.produtividadeEsperadaTha,
      referenciaAbsorcaoKgPorT: absorcaoSelecionada?.valuePerTon,
      qualidadeReferenciaAbsorcao:
          absorcaoSelecionada?.quality.title ?? 'Não usado',
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

String _asString(dynamic value, String fallback) {
  final text = value?.toString() ?? '';
  return text.trim().isEmpty ? fallback : text;
}

double _asNum(dynamic value, double fallback) {
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }
  return fallback;
}

double _required(double? value, String label) {
  if (value == null) {
    throw StateError('$label ausente na análise.');
  }
  return value;
}

bool _corrigirSolo(Map<String, dynamic> fosforo) {
  final explicit = fosforo['corrigirSolo'];
  if (explicit is bool) return explicit;
  final modo = _asString(fosforo['modoCalculo'], 'Correção do solo');
  return modo.contains('Correção');
}

ReposicaoFosforo _reposicao(Map<String, dynamic> fosforo) {
  final explicit = _asString(fosforo['reposicaoFosforo'], '');
  if (explicit == 'exportacao') return ReposicaoFosforo.exportacao;
  if (explicit == 'extracao') return ReposicaoFosforo.extracao;
  if (explicit == 'nenhuma') return ReposicaoFosforo.nenhuma;
  final modo = _asString(fosforo['modoCalculo'], '');
  if (modo.contains('Manutenção') || modo.contains('Exportação')) {
    return ReposicaoFosforo.exportacao;
  }
  if (modo.contains('Extração')) return ReposicaoFosforo.extracao;
  return ReposicaoFosforo.nenhuma;
}

double? _p2O5PorAbsorcao({
  required String tipoFonte,
  required String fonteNome,
  required String tipoDado,
  required double? produtividadeEsperadaTha,
}) {
  final prodTha = produtividadeEsperadaTha;
  if (prodTha == null || prodTha <= 0) return null;
  final resolved = _absorcaoP(
    tipoFonte: tipoFonte,
    fonteNome: fonteNome,
    tipoDado: tipoDado,
  );
  if (resolved == null) return null;
  return resolved.valuePerTon * prodTha * 2.29;
}

AbsorcaoNutrientesResolvedValue? _absorcaoP({
  required String tipoFonte,
  required String fonteNome,
  required String tipoDado,
}) {
  if (fonteNome.trim().isEmpty) return null;
  final resolved = const AbsorcaoNutrientesResolver().resolve(
    sourceType: tipoFonte,
    sourceName: fonteNome,
    dataType: tipoDado,
    nutrient: 'P',
  );
  return resolved.valuePerTon > 0 ? resolved : null;
}

String _fonteAbsorcao(Map<String, dynamic> fosforo, String tipoFonte) {
  final fonte = _asString(fosforo['fosforoFonteNome'], '');
  if (fonte.isNotEmpty) return fonte;
  final fontes = AbsorcaoNutrientesResolver.sourceNames(tipoFonte);
  return fontes.isEmpty ? '' : fontes.first;
}

double _extracaoP2O5(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 110.0;
  if (c.contains('algod')) return 130.0;
  if (c.contains('feij')) return 90.0;
  return 100.0;
}

double _exportacaoP2O5(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 60.0;
  if (c.contains('algod')) return 60.0;
  if (c.contains('feij')) return 30.0;
  return 70.0;
}

String _resumo({
  required String modo,
  required double pAtual,
  required double nc,
  required double fep,
  required double percentualUsoSolo,
}) {
  final solo = percentualUsoSolo > 0
      ? ' Extração abate ${percentualUsoSolo.toStringAsFixed(0)}% do P do solo.'
      : '';
  return 'Modo: $modo. P atual ${pAtual.toStringAsFixed(1)} mg/dm³; '
      'NC ${nc.toStringAsFixed(1)} mg/dm³; FEP ${fep.toStringAsFixed(1)}%.$solo';
}
