import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:intl/intl.dart';

class AnaliseCardWidget extends StatelessWidget {
  final AnaliseSolo analise;
  final VoidCallback onTap;

  const AnaliseCardWidget({
    super.key,
    required this.analise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDemo = analise.id.startsWith('demo_');
    final card = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarja com a cor da cultura
            Container(
              height: 6,
              color: analise.cultura.color,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        analise.cultura.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        DateFormat('dd/MM/yy').format(analise.dataCadastro),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final valor = analise.talhao;
                    final isVazio = valor.isEmpty || valor == 'N/A' || valor == 'null';
                    return Text(
                      isVazio ? 'Área não informada' : valor,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isVazio ? Colors.orange : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Builder(builder: (context) {
                        final valor = analise.produtor;
                        final isVazio = valor.isEmpty || valor == 'N/A' || valor == 'null';
                        return Expanded(
                          child: Text(
                            isVazio ? 'Produtor não informado' : valor,
                            style: TextStyle(
                              fontSize: 12,
                              color: isVazio ? Colors.orange : Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Builder(builder: (context) {
                        final valor = analise.safra;
                        final isVazio = valor.isEmpty || valor == 'N/A' || valor == 'null';
                        return Text(
                          isVazio ? 'Safra não informada' : valor,
                          style: TextStyle(
                            fontSize: 12,
                            color: isVazio ? Colors.orange : Colors.grey[700],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (!isDemo) return card;

    return Stack(
      children: [
        card,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF007AFF).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'DEMO',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );  }
}
