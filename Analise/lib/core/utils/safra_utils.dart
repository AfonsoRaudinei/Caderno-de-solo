/// Calcula a safra agrícola brasileira a partir de uma data.
///
/// Regra: meses jan–jun → safra começa no ano anterior.
///        meses jul–dez → safra começa no ano corrente.
///
/// Exemplos:
///   DateTime(2024, 8, 14) → "2024/2025"
///   DateTime(2024, 3, 10) → "2023/2024"
///   DateTime(2025, 1, 5)  → "2024/2025"
String calcularSafra(DateTime data) {
  final ano = data.year;
  final mes = data.month;
  if (mes >= 7) {
    return '$ano/${ano + 1}';
  } else {
    return '${ano - 1}/$ano';
  }
}
