import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class AnalisePastaCardLabels {
  const AnalisePastaCardLabels({
    required this.titulo,
    required this.subtitulo,
    required this.detalhe,
  });

  final String titulo;
  final String subtitulo;
  final String detalhe;
}

class AnaliseAmostraCardLabels {
  const AnaliseAmostraCardLabels({
    required this.titulo,
    required this.subtitulo,
    required this.detalhe,
  });

  final String titulo;
  final String subtitulo;
  final String detalhe;
}

AnalisePastaCardLabels buildPastaCardLabels({
  required String produtor,
  required String fazenda,
  required String laboratorio,
  required String os,
}) {
  final produtorT = produtor.trim();
  final fazendaT = fazenda.trim();
  final labT = laboratorio.trim();
  final osT = os.trim();

  final titulo = produtorT.isNotEmpty
      ? produtorT
      : (fazendaT.isNotEmpty
          ? fazendaT
          : (labT.isNotEmpty ? labT : 'Sem identificação'));

  final subtitulo = produtorT.isNotEmpty && fazendaT.isNotEmpty
      ? fazendaT
      : (produtorT.isEmpty && labT.isNotEmpty ? labT : '');

  final detalhePartes = <String>[
    if (produtorT.isNotEmpty && labT.isNotEmpty) labT,
    if (osT.isNotEmpty) 'O.S. $osT',
  ];

  return AnalisePastaCardLabels(
    titulo: titulo,
    subtitulo: subtitulo,
    detalhe: detalhePartes.join(' · '),
  );
}

AnaliseAmostraCardLabels buildAmostraCardLabels(AnaliseSolo analise) {
  final talhao =
      analise.talhao.trim().isEmpty ? 'Sem talhão' : analise.talhao.trim();
  final numero = analise.numeroAmostra.trim();
  final profundidade = analise.profundidade.trim();
  final culturaSafra = analise.safra.trim().isEmpty
      ? analise.cultura.label
      : '${analise.cultura.label} · ${analise.safra}';

  final subtitulo = numero.isNotEmpty ? numero : culturaSafra;

  final detalhePartes = <String>[
    if (numero.isNotEmpty) culturaSafra,
    if (profundidade.isNotEmpty) profundidade,
    if (analise.fazenda.trim().isNotEmpty) analise.fazenda.trim(),
  ];

  return AnaliseAmostraCardLabels(
    titulo: talhao,
    subtitulo: subtitulo,
    detalhe: detalhePartes.join(' · '),
  );
}

String buildPastaHeaderTitulo({
  required String produtor,
  required String fazenda,
  required String os,
}) {
  final labels = buildPastaCardLabels(
    produtor: produtor,
    fazenda: fazenda,
    laboratorio: '',
    os: os,
  );
  if (labels.detalhe.isNotEmpty) {
    return '${labels.titulo} · ${labels.detalhe}';
  }
  if (labels.subtitulo.isNotEmpty) {
    return '${labels.titulo} · ${labels.subtitulo}';
  }
  return labels.titulo;
}
