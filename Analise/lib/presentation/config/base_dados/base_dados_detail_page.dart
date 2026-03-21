import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';

class BaseDadosDetailPage extends StatelessWidget {
  const BaseDadosDetailPage({super.key, required this.referencia});

  final ReferenciaTecnica referencia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Detalhe da Referência'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(referencia.arquivoMarkdown),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar o arquivo:\n${referencia.arquivoMarkdown}',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final conteudo = snapshot.data ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referencia.nome,
                      style: AppTextStyles.headline.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${referencia.autor} · ${referencia.anoPublicacao} · ${referencia.instituicao}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF86868B)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${referencia.tipo} • Ano: ${referencia.ano} • Fórmula: ${referencia.formulaAssociada}',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      referencia.arquivoMarkdown,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Markdown(
                  data: conteudo,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                      letterSpacing: -0.3,
                    ),
                    h2: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                      letterSpacing: -0.2,
                    ),
                    p: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1D1F),
                      height: 1.6,
                    ),
                    strong: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                    ),
                    code: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier',
                      backgroundColor: Color(0xFFF5F5F7),
                      color: Color(0xFF007AFF),
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E5E7),
                        width: 0.5,
                      ),
                    ),
                    blockquoteDecoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF007AFF), width: 3),
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.only(left: 12),
                    tableHead: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    tableBody: const TextStyle(fontSize: 13),
                    horizontalRuleDecoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E5E7),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
