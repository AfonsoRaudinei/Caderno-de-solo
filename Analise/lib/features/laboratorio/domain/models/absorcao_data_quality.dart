/// Qualidade do valor de absorção/exportação resolvido.
enum AbsorcaoDataQuality {
  original,
  calculated,
  unavailable;

  String get title => switch (this) {
        AbsorcaoDataQuality.original => 'Original',
        AbsorcaoDataQuality.calculated => 'Calculado',
        AbsorcaoDataQuality.unavailable => 'Indisponível',
      };

  String get subtitle => switch (this) {
        AbsorcaoDataQuality.original => 'Valor direto da fonte selecionada',
        AbsorcaoDataQuality.calculated => 'Estimado por índice de exportação',
        AbsorcaoDataQuality.unavailable =>
          'Sem base para calcular este nutriente',
      };
}
