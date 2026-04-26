import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';

class BaseDadosFormPage extends StatelessWidget {
  const BaseDadosFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Nova Referência'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  const AppInput(
                    label: 'Nome da Referência',
                    hint: 'Ex: Boletim 100 IAC',
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Tipo',
                    hint: 'Selecione',
                    value: null,
                    items: const ['Boletim', 'Tese', 'Artigo', 'Embrapa', 'IAC', 'Outro']
                        .map((e) => AppDropdownItem(value: e, label: e))
                        .toList(),
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),
                  const AppInput(
                    label: 'Autor(es)',
                    hint: 'Nomes dos autores principais',
                  ),
                  const SizedBox(height: 16),
                  const AppInput(
                    label: 'Ano de Publicação',
                    hint: 'Ex: 2022',
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Fórmula associada',
                    hint: 'Selecione para qual cálculo',
                    value: null,
                    items: const ['Calcário', 'Gesso', 'P', 'K', 'S', 'Micro']
                        .map((e) => AppDropdownItem(value: e, label: e))
                        .toList(),
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),
                  const AppInput(
                    label: 'Descrição',
                    hint: 'Breve resumo ou anotações (opcional)',
                  ),
                  const SizedBox(height: 16),
                  const AppInput(
                    label: 'Link/DOI',
                    hint: 'https://doi.org/... (opcional)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar Referência',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referência salva com sucesso!')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
