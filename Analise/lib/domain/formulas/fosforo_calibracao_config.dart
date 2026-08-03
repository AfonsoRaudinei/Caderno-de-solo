/// Configuração tipada do card de calibração de Fósforo.
///
/// Faz parse de [Map] persistido com retrocompatibilidade para calibrações
/// antigas que usavam apenas `modoCalculo` e `tipoDadoCultivar`.
enum ModoReposicaoP { semReposicao, exportacao, extracao }

extension ModoReposicaoPLabel on ModoReposicaoP {
  String get label {
    switch (this) {
      case ModoReposicaoP.semReposicao:
        return 'Sem reposição';
      case ModoReposicaoP.exportacao:
        return 'Exportação';
      case ModoReposicaoP.extracao:
        return 'Extração';
    }
  }

  String get fosforoModoAbsorcao {
    switch (this) {
      case ModoReposicaoP.exportacao:
        return 'exportacao';
      case ModoReposicaoP.extracao:
      case ModoReposicaoP.semReposicao:
        return 'extracao';
    }
  }
}

class FosforoCalibracaoConfig {
  const FosforoCalibracaoConfig({
    required this.correcaoSoloAtiva,
    required this.modoReposicao,
    required this.ajusteEficienciaSolo,
    required this.percentualUsoPSolo,
  });

  final bool correcaoSoloAtiva;
  final ModoReposicaoP modoReposicao;
  final double ajusteEficienciaSolo;
  final double percentualUsoPSolo;

  /// Retrocompatível: calibrações sem os novos campos continuam válidas.
  factory FosforoCalibracaoConfig.fromMap(Map<String, dynamic> map) {
    final modoCalculo = map['modoCalculo']?.toString() ?? '';
    final tipoDado = map['tipoDadoCultivar']?.toString() ?? '';
    final fosforoModoAbsorcao =
        map['fosforoModoAbsorcao']?.toString() ?? 'extracao';

    final correcaoSoloAtiva = _parseBool(
      map['correcaoSoloAtiva'],
      fallback: modoCalculo.contains('Correção') || modoCalculo.startsWith('①'),
    );

    final modoReposicao = _parseModoReposicao(
      map['modoReposicao']?.toString(),
      modoCalculo: modoCalculo,
      tipoDado: tipoDado,
      fosforoModoAbsorcao: fosforoModoAbsorcao,
    );

    return FosforoCalibracaoConfig(
      correcaoSoloAtiva: correcaoSoloAtiva,
      modoReposicao: modoReposicao,
      ajusteEficienciaSolo: _clampPercentual(
        _parseNum(map['ajusteEficienciaSolo'], fallback: 0),
      ),
      percentualUsoPSolo: _clampPercentual(
        _parseNum(map['percentualUsoPSolo'], fallback: 0),
      ),
    );
  }

  /// Rótulo legado de `modoCalculo` para consumidores antigos.
  String get modoCalculoLegado {
    if (correcaoSoloAtiva && modoReposicao == ModoReposicaoP.semReposicao) {
      return '① Correção do solo';
    }
    switch (modoReposicao) {
      case ModoReposicaoP.extracao:
        return '② Extração';
      case ModoReposicaoP.exportacao:
        return 'Manutenção';
      case ModoReposicaoP.semReposicao:
        return correcaoSoloAtiva ? '① Correção do solo' : 'Sem reposição';
    }
  }

  Map<String, dynamic> toPayload({
    required Map<String, dynamic> base,
    required String cultura,
    required Map<String, dynamic> camposTecnicos,
  }) {
    return {
      ...base,
      ...camposTecnicos,
      'correcaoSoloAtiva': correcaoSoloAtiva,
      'modoReposicao': modoReposicao.label,
      'ajusteEficienciaSolo': ajusteEficienciaSolo,
      'percentualUsoPSolo': percentualUsoPSolo,
      'cultivar': cultura,
      'modoCalculo': modoCalculoLegado,
      'tipoDadoCultivar': modoReposicao == ModoReposicaoP.exportacao
          ? 'Exportação'
          : 'Manutenção',
      'fosforoModoAbsorcao': modoReposicao.fosforoModoAbsorcao,
    };
  }

  static ModoReposicaoP _parseModoReposicao(
    String? value, {
    required String modoCalculo,
    required String tipoDado,
    required String fosforoModoAbsorcao,
  }) {
    switch (value) {
      case 'Sem reposição':
        return ModoReposicaoP.semReposicao;
      case 'Exportação':
        return ModoReposicaoP.exportacao;
      case 'Extração':
        return ModoReposicaoP.extracao;
    }

    final isCorrecaoLegado = modoCalculo.contains('Correção') ||
        modoCalculo.startsWith('①') ||
        modoCalculo.startsWith('⓪');
    final isExtracaoLegado =
        modoCalculo.contains('Extração') || modoCalculo.contains('②');
    final isExportacaoLegado = modoCalculo.contains('Manutenção') ||
        (modoCalculo.contains('Exportação') && !isCorrecaoLegado);

    if (isExtracaoLegado) {
      return ModoReposicaoP.extracao;
    }
    if (isExportacaoLegado) {
      return ModoReposicaoP.exportacao;
    }
    if (isCorrecaoLegado) {
      return ModoReposicaoP.semReposicao;
    }

    if (tipoDado == 'Exportação' || fosforoModoAbsorcao == 'exportacao') {
      return ModoReposicaoP.exportacao;
    }
    if (tipoDado == 'Manutenção') {
      return ModoReposicaoP.extracao;
    }
    return ModoReposicaoP.semReposicao;
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  static double _parseNum(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
    }
    return fallback;
  }

  static double _clampPercentual(double value) =>
      value.clamp(0.0, 100.0).toDouble();
}

/// Valida percentual 0–100. Retorna mensagem de erro ou null se válido.
String? validarPercentualFosforo(double? value) {
  if (value == null) return 'Informe um valor numérico';
  if (value < 0) return 'Mínimo: 0%';
  if (value > 100) return 'Máximo: 100%';
  return null;
}
