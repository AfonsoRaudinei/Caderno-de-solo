# SoloForte — Culturas · Plano de Execução Claude Code

**Usar em:** Google Project IDX · Claude Code  
**Referência:** `SoloForte_Culturas_Screen_Prompt.md`  
**Arquivo de dados:** `culturas_data.dart`  
**Sequência:** 6 prompts · executar UM por vez · aguardar conclusão antes do próximo

---

## ANTES DE COMEÇAR

Cole este bloco UMA VEZ no início da sessão do Claude Code:

```
Contexto fixo para toda a sessão:
- App: SoloForte · Flutter/Dart · Riverpod · iOS design
- Design system: cor primária #007AFF, background #F5F5F7, cards brancos com border-radius 16
- Fonte: -apple-system / SF Pro
- Todos os arquivos novos vão em lib/ conforme estrutura abaixo
- Não usar setState — apenas Riverpod (StateNotifier + Provider)
- Não criar testes agora
- Referência visual aprovada: protótipo com 3 pills + dropdown + grid nutrientes + result card com toggle 3 opções
```

---

## PROMPT 1 — Dados e Modelos

```
Crie o arquivo lib/data/culturas_data.dart com o conteúdo EXATO
do arquivo culturas_data.dart que está na pasta PROMPT/extracao e exportacao/.

Não altere nenhum valor numérico.
Não remova nenhuma entrada.
Apenas adicione o import do Flutter no topo:
  import 'package:flutter/material.dart';

Confirme ao final quantos cultivares, autores e tecnologias foram incluídos.
```

**Verificar:** arquivo criado em `lib/data/culturas_data.dart` · sem erros de sintaxe

---

## PROMPT 2 — Provider

```
Crie o arquivo lib/features/culturas/providers/culturas_provider.dart

Regras:
- Usar Riverpod StateNotifier
- Estado: CulturasState com campos:
    SourceType? sourceType
    String? selectedSource
    List<String> selectedNutrients  (padrão: ['N','P','K'])
    DataMode dataMode               (padrão: DataMode.exportacao)
- Método toggleNutrient: máximo 3 simultâneos, FIFO ao exceder, mínimo 1
- Método setSourceType: limpa selectedSource ao trocar
- Provider sourcesListProvider: retorna lista de nomes para o tipo ativo
- Provider currentEntryProvider: retorna SourceEntry? da seleção atual

Importar: package:soloforte/data/culturas_data.dart
```

**Verificar:** `flutter analyze lib/features/culturas/providers/` sem erros

---

## PROMPT 3 — Widgets (4 arquivos)

```
Crie os 4 widgets abaixo em lib/features/culturas/widgets/

── 1. source_type_pills.dart ──────────────────────────────────
ConsumerWidget com Row de 3 pills animados (AnimatedContainer 180ms)
Pills: Autor (Icons.people_outline) | Cultivar (Icons.grass_outlined) | Tecnologia (Icons.wb_sunny_outlined)
Selecionado: border #007AFF + background #F0F6FF + texto #007AFF
Não selecionado: border #E5E5EA + background branco + texto #86868B

── 2. source_dropdown.dart ────────────────────────────────────
ConsumerWidget com DropdownButtonHideUnderline
Container com border 1.5px: #E5E5EA vazio · #007AFF preenchido
Hint: "Escolher..." em #C7C7CC
Items vindos de sourcesListProvider
onChange chama setSelectedSource

── 3. nutrient_selector.dart ──────────────────────────────────
ConsumerWidget com GridView.count crossAxisCount:5 crossAxisSpacing:6 mainAxisSpacing:6
10 nutrientes: N P K Ca Mg S Fe Zn Mn B
Selecionado: background e border na cor do nutriente · texto branco
Não selecionado: border #E5E5EA · texto #86868B
onTap chama toggleNutrient

── 4. result_card.dart ────────────────────────────────────────
ConsumerWidget — retorna SizedBox.shrink() se currentEntryProvider == null

Estrutura do card (border-radius 16, border 0.5px #E5E5EA):
  [Header] nome + tag colorida (Autor=#007AFF · Cultivar=#34C759 · Tecnologia=#FF9500)
  [Toggle] 3 botões: Exportação | Extração | %
    Container height:34 background:#F0F0F5 border-radius:10 padding:2
    Ativo: background branco + shadow sutil + texto #1D1D1F bold
    Inativo: transparente + texto #86868B
  [Barras] — 3 modos:
    Exportação/Extração: por nutriente selecionado
      Row(nome, valor+unidade) + LinearProgressIndicator animado (TweenAnimationBuilder 450ms)
    Percentual: legenda + 2 barras por nutriente
      Exp% = (exportacao ÷ extracao) × 100  → cor #34C759
      Ext% = (extracao ÷ exportacao) × 100  → cor #007AFF · escala cap 300%

Cores dos nutrientes (da kNutrients):
  N=#007AFF P=#34C759 K=#FF9500 Ca=#AF52DE Mg=#FF2D55 S=#5AC8FA
  Fe=#8E6C3D Zn=#636366 Mn=#1C7A4A B=#C0392B
```

**Verificar:** `flutter analyze lib/features/culturas/widgets/` sem erros

---

## PROMPT 4 — Tela Principal

```
Crie lib/features/culturas/screens/culturas_screen.dart

Scaffold com:
  backgroundColor: Color(0xFFF5F5F7)
  AppBar: título "Culturas" fontSize:20 bold · fundo branco · elevation 0 · scrolledUnderElevation 0.5

Body: SingleChildScrollView padding:16 com Column:
  1. Text "TIPO DE FONTE" (label section: 11px, uppercase, #86868B, letterSpacing 0.5)
  2. SizedBox(height:8)
  3. SourceTypePills()
  4. SizedBox(height:20)
  5. if (state.sourceType != null):
       label dinâmico ("SELECIONAR AUTOR" | "SELECIONAR CULTIVAR" | "SELECIONAR TECNOLOGIA")
       SizedBox(height:8)
       SourceDropdown()
       SizedBox(height:20)
  6. if (state.selectedSource != null):
       Text "NUTRIENTES (ATÉ 3)" (mesmo estilo label)
       SizedBox(height:8)
       NutrientSelector()
       SizedBox(height:20)
       ResultCard()
       SizedBox(height:32)

Importar todos os widgets criados no Prompt 3.
```

**Verificar:** tela renderiza sem overflow · hot reload funciona

---

## PROMPT 5 — Registrar na Bottom Bar

```
Atualize o arquivo de navegação principal do app (provavelmente
lib/main.dart ou lib/navigation/main_navigation.dart ou similar —
identifique o arquivo correto antes de editar).

Mudanças:
1. Adicionar import: package:soloforte/features/culturas/screens/culturas_screen.dart
2. Inserir CulturasScreen() como 4ª tela (índice 3), empurrando Config para índice 4
3. Adicionar BottomNavigationBarItem na posição 3:
     icon: Icon(Icons.grass_outlined)
     label: 'Culturas'
4. Garantir que o type do BottomNavigationBar é BottomNavigationBarType.fixed
5. Não alterar lógica das outras telas

Antes de editar, mostre qual arquivo você identificou como o de navegação.
```

**Verificar:** 5 abas visíveis · tocar em "Culturas" abre a tela correta

---

## PROMPT 6 — Revisão Final

```
Execute as seguintes verificações no módulo Culturas:

1. flutter analyze lib/features/culturas/ lib/data/culturas_data.dart
   → corrigir todos os warnings e erros

2. Verificar que TweenAnimationBuilder nas barras usa:
   curve: Curves.easeOutCubic
   duration: Duration(milliseconds: 450)

3. Verificar que AnimatedContainer nas pills usa:
   duration: Duration(milliseconds: 180)

4. Verificar que toggleNutrient respeita:
   - máximo 3 selecionados (FIFO)
   - mínimo 1 (não permite deselecionar o último)

5. Verificar que setSourceType limpa selectedSource

6. Se encontrar algum problema, corrigir e reportar o que foi ajustado.
```

---

## CHECKLIST FINAL

Após os 6 prompts, confirme:

- [ ] `lib/data/culturas_data.dart` — 47 cultivares · 10 autores · 3 tecnologias
- [ ] `lib/features/culturas/providers/culturas_provider.dart` — sem erros
- [ ] 4 widgets em `lib/features/culturas/widgets/` — sem erros
- [ ] `lib/features/culturas/screens/culturas_screen.dart` — renderiza
- [ ] Bottom bar com 5 abas — Culturas na posição 4
- [ ] Fluxo completo funciona: pill → dropdown → nutrientes → resultado → toggle %

---

## ESTRUTURA FINAL ESPERADA

```
lib/
├── data/
│   └── culturas_data.dart
└── features/
    └── culturas/
        ├── providers/
        │   └── culturas_provider.dart
        ├── screens/
        │   └── culturas_screen.dart
        └── widgets/
            ├── source_type_pills.dart
            ├── source_dropdown.dart
            ├── nutrient_selector.dart
            └── result_card.dart
```

---

*Execute um prompt por vez. Aguarde o Claude Code confirmar conclusão antes de avançar.*
