enum MetodoGesso {
  argilaEmbrapa,
  tabelaTexturaUfla,
  vPctCtcSubEsalq,
  ctcEfetivaCaUepg,
  sodico,
  excessoPotassio,
}

extension MetodoGessoExt on MetodoGesso {
  String get nome {
    switch (this) {
      case MetodoGesso.argilaEmbrapa:
        return 'Argila (EMBRAPA)';
      case MetodoGesso.tabelaTexturaUfla:
        return 'Tabela Textural (UFLA)';
      case MetodoGesso.vPctCtcSubEsalq:
        return 'V% e CTC Subsolo (ESALQ)';
      case MetodoGesso.ctcEfetivaCaUepg:
        return 'CTCe e Ca Subsolo (UEPG)';
      case MetodoGesso.sodico:
        return 'Solo Sódico';
      case MetodoGesso.excessoPotassio:
        return 'Excesso de K';
    }
  }
}

class DiagnosticoGesso {
  const DiagnosticoGesso({
    required this.indicado,
    required this.caSubBaixo,
    required this.alSubAlto,
    required this.mSubAlto,
    required this.motivos,
  });

  final bool indicado;
  final bool caSubBaixo;
  final bool alSubAlto;
  final bool mSubAlto;
  final List<String> motivos;
}

class ResultadoGesso {
  const ResultadoGesso({
    required this.metodo,
    required this.indicado,
    required this.doseKgHa,
    required this.doseTHa,
    required this.sFornecidoKgHa,
    required this.caFornecidoKgHa,
    required this.caAumentoCmolcDm3,
    required this.observacoes,
  });

  final MetodoGesso metodo;
  final bool indicado;
  final double doseKgHa;
  final double doseTHa;
  final double sFornecidoKgHa;
  final double caFornecidoKgHa;
  final double caAumentoCmolcDm3;
  final List<String> observacoes;
}
