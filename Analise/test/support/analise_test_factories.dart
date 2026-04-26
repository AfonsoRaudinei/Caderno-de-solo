import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

AnaliseSolo makeAnalise({
  required String id,
  required String talhao,
  String numeroAmostra = '',
  String fazenda = 'Fazenda Teste',
  String produtor = 'Produtor Teste',
  String laboratorio = 'Sellar',
  String safra = '2025/2026',
  String profundidade = '0-20',
  double? phCaCl2 = 5.3,
  double? k = 0.31,
  double? ca = 3.1,
  double? mg = 1.2,
  Map<String, dynamic>? laudoMetadata,
}) {
  return AnaliseSolo(
    id: id,
    fazenda: fazenda,
    produtor: produtor,
    talhao: talhao,
    numeroAmostra: numeroAmostra,
    cultura: Cultura.soja,
    safra: safra,
    laboratorio: laboratorio,
    dataCadastro: DateTime(2026, 4, 6, 10, 0),
    profundidade: profundidade,
    phCaCl2: phCaCl2,
    k: k,
    ca: ca,
    mg: mg,
    laudoMetadata: laudoMetadata,
  );
}
