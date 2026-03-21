import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? suffixText;

  const NumFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(7),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffixText,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
      ),
    );
  }
}
