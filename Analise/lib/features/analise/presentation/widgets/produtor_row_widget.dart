import 'package:flutter/material.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';

class ProdutorRowWidget extends StatelessWidget {
  final Produtor produtor;

  const ProdutorRowWidget({super.key, required this.produtor});

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          _getInitials(produtor.nome),
          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(produtor.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(produtor.fazenda),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '${produtor.totalAnalises} ${produtor.totalAnalises == 1 ? "análise" : "análises"}',
          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
        ),
      ),
    );
  }
}
