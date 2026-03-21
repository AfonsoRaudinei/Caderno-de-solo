// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class UploadPdfWidget extends StatelessWidget {
  final VoidCallback onTap;

  const UploadPdfWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.withOpacity(0.5),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.upload_file, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Importar Laudo PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preencha os campos automaticamente via template do laboratório.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
