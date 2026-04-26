import 'package:flutter/services.dart';

/// Limita o número de DÍGITOS numéricos (0-9) no campo.
/// O separador decimal (vírgula ou ponto) NÃO conta no limite.
/// Exemplos com maxDigits=7:
///   "0,001234"  -> 6 dígitos -> permitido
///   "13,800"    -> 5 dígitos -> permitido
///   "12345678"  -> 8 dígitos -> bloqueado
///   "0,0001234" -> 7 dígitos -> permitido
class DigitLimitFormatter extends TextInputFormatter {
  final int maxDigits;

  const DigitLimitFormatter({this.maxDigits = 7});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitCount = newValue.text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount > maxDigits) return oldValue;
    return newValue;
  }
}
