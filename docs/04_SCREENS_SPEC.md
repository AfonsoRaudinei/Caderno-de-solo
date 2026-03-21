# 04 — Screens Spec (Bottom Nav: Análise, Lab, Histórico, Config)

> **Status geral:** ✅ telas principais codificadas. Formulário de inserção de análise foi completamente reescrito (v2) para cobrir 4 laboratórios reais (Exata Brasil, Sellar/Embrapa, MB Agronegócios, IBRA).
> **Atualização de alinhamento:** `MainPage` e `LabPage` estão com escopo de 4 abas principais e 2 tabs internas no Lab.

## Análise (tab principal)

- **AppBar:** título `Análise de Solo`, filtro de contexto e botão `+` para criar nova análise.
- **Filtros:** campo de busca (produtor/área), chips `FilterChipsWidget` para Cultura, dropdowns de safra, produtor e status (implícitos no provider).
- **Conteúdo:**
  - Lista de produtores (Provider `analiseRepositoryProvider.getProdutores()` → `ProdutorRowWidget`).
  - Grid responsivo de `AnaliseCardWidget` (pintar tarja com cor da cultura, exibir data + safra).
  - Empty state com ícone `science_outlined`.
- **Ações:**
  - FAB azul (`AppColors.primary`) abre `/analise/nova` → `AnaliseFormPage` (v2).
  - Tocar card → `AppRoutes.analise/detalhe/:id` → `AnaliseDetailScreen`.
  - `GoRouter` mantém rota `ShellRoute` com `MainPage`.

### AnaliseFormPage (v2) — formulário completo de inserção

> Arquivo: `presentation/features/analise/analise_form_page.dart`
> Cobre: Exata Brasil, Sellar/Embrapa, MB Agronegócios, IBRA.

**Estrutura — 9 seções colapsáveis (AnimatedCrossFade):**

1. Identificação
2. pH e M.O.
3. Fósforo
4. Macronutrientes
5. Card calculados
6. Granulometria
7. Micronutrientes
8. Campos extras
9. Observações

**Comportamentos especiais:**

- Auto-configuração de unidades por extrator.
- Exibição dupla em tempo real para conversões.
- Card de calculados automático com chips de diagnóstico.
- Toggle `% / g/kg` em granulometria com conversão instantânea.
- Seletor visual de fonte P (`resina`/`mehlich`) alimentando `FosforoData.fontePrincipal`.
- Bottom bar com `Salvar rascunho` e `Concluir análise`.
- `LengthLimitingTextInputFormatter(7)` para campos numéricos.

## Lab (segunda aba) — `TabBar` Calibração + Recomendação

- **Container:** `LabPage` usa `DefaultTabController(length: 2)` com `TabBar`.
- **Calibração:** `CalibracaoPage` usa `calibracaoControllerProvider`.
- **Recomendação:** `RecomendacaoScreen` observa `recomendacaoProvider`.

## Histórico (aba três)

- Filtros no topo (data e filtros).
- Lista mock com `Dismissible` + `AppCard`.
- Empty state com ícone de relógio.

## Config (aba quatro)

- **Perfil**, **Gerenciamento**, **Sistema**.
- Rotas de Base de Dados e Feedback via GoRouter.

## Extras e inconsistências

- `Culturas` não faz parte da Bottom Navigation principal.
- `CulturasScreen` segue disponível em rota dedicada `/culturas` e por atalhos de fluxo dentro do Lab (`CalibracaoPage`).
- Recomendações subsequentes (Mapa, PDF) ficam em `AnaliseDetailScreen` como ações secundárias.
