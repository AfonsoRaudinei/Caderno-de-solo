class ValorNutriente {
  const ValorNutriente({
    required this.valor,
    required this.analisado,
  });

  final double? valor;
  final bool analisado;

  bool get isValido => analisado && valor != null;
}
