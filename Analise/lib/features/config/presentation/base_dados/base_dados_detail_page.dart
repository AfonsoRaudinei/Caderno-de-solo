import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';

class BaseDadosDetailPage extends StatelessWidget {
  const BaseDadosDetailPage({super.key, required this.referencia});

  final ReferenciaTecnica referencia;

  MarkdownStyleSheet _markdownStyle(AppThemePalette palette) {
    return MarkdownStyleSheet(
      h1: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.3,
      ),
      h2: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        letterSpacing: -0.2,
      ),
      p: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
        height: 1.6,
      ),
      strong: TextStyle(
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      code: TextStyle(
        fontSize: 12,
        fontFamily: 'Courier',
        backgroundColor: palette.cardStrong,
        color: AppColors.primary,
      ),
      codeblockDecoration: BoxDecoration(
        color: palette.cardStrong,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: palette.border,
          width: 0.5,
        ),
      ),
      blockquoteDecoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12),
      tableHead: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: palette.textPrimary,
      ),
      tableBody: TextStyle(
        fontSize: 13,
        color: palette.textPrimary,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: palette.border,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
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
                  style: AppTextStyles.body.copyWith(color: palette.textPrimary),
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
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 18,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${referencia.autor} · ${referencia.anoPublicacao} · ${referencia.instituicao}',
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${referencia.tipo} • Ano: ${referencia.ano} • Fórmula: ${referencia.formulaAssociada}',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      referencia.arquivoMarkdown,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: palette.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Markdown(
                  data: conteudo,
                  selectable: true,
                  styleSheet: _markdownStyle(palette),
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
