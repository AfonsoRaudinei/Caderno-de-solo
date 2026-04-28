import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ExtratorP { resinaIAC, mehlich1 }

enum ReferenciaP { iacBol100, embrapasCerrado, embrapaRsSc, ufla }

enum CamadaP { c0a20, c20a40 }

enum ModoCalculo { correcaoSolo, manutencao, exportacao }

enum TipoCalculo { exportacao, manutencao }

enum FaixaArgila {
  f1, // < 10%
  f2, // 10–20%
  f3, // 21–40%
  f4, // 41–60%
  f5, // > 60%
}

extension FaixaArgilaX on FaixaArgila {
  String get label {
    switch (this) {
      case FaixaArgila.f1:
        return '< 10%';
      case FaixaArgila.f2:
        return '10–20%';
      case FaixaArgila.f3:
        return '21–40%';
      case FaixaArgila.f4:
        return '41–60%';
      case FaixaArgila.f5:
        return '> 60%';
    }
  }

  double get rep {
    switch (this) {
      case FaixaArgila.f1:
        return 5;
      case FaixaArgila.f2:
        return 15;
      case FaixaArgila.f3:
        return 30;
      case FaixaArgila.f4:
        return 50;
      case FaixaArgila.f5:
        return 70;
    }
  }
}

class RefDesc {
  final String label;
  final ExtratorP extrator;
  final bool fixo;
  final bool placeholder;
  final String fonte;

  const RefDesc({
    required this.label,
    required this.extrator,
    required this.fonte,
    this.fixo = false,
    this.placeholder = false,
  });

  bool get porArgila => !fixo;

  double? resolveNc(FaixaArgila f, ReferenciaP ref) {
    if (fixo) return 30;
    switch (ref) {
      case ReferenciaP.embrapasCerrado:
        return _ncCerrado(f);
      case ReferenciaP.embrapaRsSc:
        return _ncRsSc(f);
      case ReferenciaP.ufla:
        return _ncUfla(f);
      default:
        return null;
    }
  }

  String get tooltipText {
    if (fixo) {
      return 'NC fixo definido pela referência IAC Bol.100\n'
          '(Raij et al., 1996 — Resina trocadora de ânions, SP)';
    }
    if (placeholder) {
      return 'Valores provisórios — tabela CFSEMG/UFLA pendente de confirmação.\n'
          'O NC varia por faixa de argila nesta referência (Mehlich-1).\n'
          'Substitua pelos valores de Ribeiro et al. (1999) quando disponível.';
    }
    return 'O NC varia conforme o teor de argila do solo — $fonte.\n'
        'Diferentes amostras de uma mesma propriedade podem ter texturas distintas.\n'
        'Confirme o boletim de análise antes de fixar a faixa.';
  }
}

double _ncCerrado(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 15;
    case FaixaArgila.f2:
      return 15;
    case FaixaArgila.f3:
      return 8;
    case FaixaArgila.f4:
      return 4;
    case FaixaArgila.f5:
      return 3;
  }
}

double _ncRsSc(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 21;
    case FaixaArgila.f2:
      return 18;
    case FaixaArgila.f3:
      return 12;
    case FaixaArgila.f4:
      return 9;
    case FaixaArgila.f5:
      return 6;
  }
}

double _ncUfla(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 20;
    case FaixaArgila.f2:
      return 16;
    case FaixaArgila.f3:
      return 10;
    case FaixaArgila.f4:
      return 6;
    case FaixaArgila.f5:
      return 4;
  }
}

/// Tabela principal exposta via Riverpod
final fosforoFormulaProvider = Provider<Map<ReferenciaP, RefDesc>>((ref) {
  return const <ReferenciaP, RefDesc>{
    ReferenciaP.iacBol100: RefDesc(
      label: 'IAC Bol.100',
      extrator: ExtratorP.resinaIAC,
      fonte: 'Raij et al., 1996',
      fixo: true,
    ),
    ReferenciaP.embrapasCerrado: RefDesc(
      label: 'Embrapa Cerrado',
      extrator: ExtratorP.mehlich1,
      fonte: 'Sousa & Lobato, 2004',
    ),
    ReferenciaP.embrapaRsSc: RefDesc(
      label: 'Embrapa RS/SC',
      extrator: ExtratorP.mehlich1,
      fonte: 'CQFS RS/SC, 2004',
    ),
    ReferenciaP.ufla: RefDesc(
      label: 'UFLA / CFSEMG',
      extrator: ExtratorP.mehlich1,
      fonte: 'CFSEMG, 1999 (pendente)',
      placeholder: true,
    ),
  };
});
