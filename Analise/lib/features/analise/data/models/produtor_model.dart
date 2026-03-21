import 'package:soloforte/features/analise/domain/entities/produtor.dart';

class ProdutorModel extends Produtor {
  const ProdutorModel({
    required super.id,
    required super.nome,
    required super.fazenda,
    super.totalAnalises,
  });

  factory ProdutorModel.fromJson(Map<String, dynamic> json) {
    return ProdutorModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      fazenda: json['fazenda'] as String,
      totalAnalises: json['totalAnalises'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'fazenda': fazenda,
      'totalAnalises': totalAnalises,
    };
  }
}
