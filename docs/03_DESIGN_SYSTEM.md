# 03 — Design System iOS/Apple (SoloForte)

> **Status:** ✅ tokens aplicados em `core/theme` e nos widgets reutilizáveis.

## Paleta de cores (iOS-inspired)

| Token | Valor | Uso principal |
| --- | --- | --- |
| `AppColors.primary` | `#007AFF` | Interações principais, botões primários, ícones selecionados. |
| `AppColors.primaryDark` | `#0051D5` | Gradiente do botão primário, sombras. |
| `AppColors.bgPrimary` | `#FFFFFF` | Papel principal. |
| `AppColors.bgSecondary` | `#F5F5F7` | Fundo das telas e cards em branco. |
| `AppColors.textPrimary` | `#1D1D1F` | Texto principal. |
| `AppColors.textSecond` | `#86868B` | Texto secundário, labels. |
| `AppColors.border` / `borderSoft` | `#D1D1D6` / `#E5E5E7` | Linhas, inputs, chips. |
| `AppColors.success` | `#34C759` | Resultados positivos (status, badges). |
| `AppColors.error` | `#FF3B30` | Erros e feedback vermelho. |
| Nutrientes (calcário, gesso, potássio, fosforo, enxofre, micronut) | Cores específicas (ex: `#5AC8FA`, `#FFCC00`, `#FF9500`, `#FF3B30`, `#34C759`, `#AF52DE`) | Bordas laterais dos `NutrienteCard` e legendas do Lab.

## Tipografia e hierarquia

| Token | Estilo | Tamanho + peso |
| --- | --- | --- |
| `AppTextStyles.sectionLabel` | Uppercase, espaçamento | 12px, w500, `textSecond` |
| `AppTextStyles.body` | Texto base | 15px, w400 |
| `AppTextStyles.label` | Labels e subtítulos | 14px, w500 |
| `AppTextStyles.value` | Valores destacados | 17px, w600 |
| `AppTextStyles.headline` | Títulos de destaque | 22px, w700 |
| `AppTextStyles.largeTitle` | Header principal (Login) | 28px, w700 |
| `AppTextStyles.caption` | Rodapés | 12px, w400, `textSecond` |

Font-family: `.SF Pro Text` (fallback Roboto). Texts slightly letter-spaced e com `leadingDistribution: TextLeadingDistribution.even` para a pegada iOS.

## Tokens de espaçamento (AppDimens)

- `xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=20`, `xxl=24`, `section=32`.  
- Bordas: `radiusSm=8`, `radiusMd=12`, `radiusLg=16`, `radiusXl=20`.  
- Alturas fixas: `buttonHeight=50`, `inputHeight=44`, `cardPadding=20`, `screenPadding=16`, `iconSize=24`.

## Componentes reutilizáveis

### AppButton / AppButtonSecondary / AppButtonText
- Botão primário com gradiente `#007AFF → #0051D5`, altura 50, radius 12, animação de `ScaleTransition`, spinner durante `isLoading`.  
- Secundário: fundo `AppColors.borderSoft`, texto `AppColors.textSecond`.  
- Texto: link azul com padding compacto.

### AppCard / AppCardSection / AppCardRow
- Fundo branco levemente translúcido (`alpha 0.95`), borda `0.5px`, sombra suave.  
- Estrutura `AppCardSection` combina label uppercase + card.  
- `AppCardRow` exibe label + valor com divider opcional.

### AppInput / AppInputNumerico / AppTextArea / NumFieldWidget
- Bordas arredondadas (8px), placeholders cinza, foco com sombra azul suave.  
- `AppInput` suporta `maxLength` (default 7 para campos numéricos) e exibe `errorText` manual.  
- `AppInputNumerico` + `NumFieldWidget` combinam `LengthLimitingTextInputFormatter(7)` com `FilteringTextInputFormatter.allow(RegExp(r'^\\d*\\.?\\d*'))`, garantindo que **inputs numéricos nunca excedem 7 dígitos nem aceitem caracteres inválidos.**  
- `AppTextArea` usa `TextInputAction.newline` e `maxLines=6`.

### AppDropdown
- Dropdown estilizado com borda `#D1D1D6`, radius 8 e ícone `keyboard_arrow_down`.  
- Usado em perfis, culturas, estados, tipos de referências e escolha de método.

### NutrienteCard
- Card expansível (accordion) com barra lateral colorida, animações (rotações, cross-fade).  
- Ideal para encapsular grupos como `Corretivos`, `Fósforo`, `Potássio`, `Micronutrientes`.

## Navegação e layouts principais

- `MainPage` usa `NavigationBar` (Material 3) com background branco, indicador azul (`alpha 0.1`), texto `#CED1` desativado e ícones do sistema (science, biotech, history, grass, settings).  
- `LabPage` mantém `DefaultTabController(length: 2)` com `TabBar` e `TabBarView` (Calibração + Recomendação).  
- `BottomNavigationBar`: quatro abas ideais (Análise, Lab, Histórico, Config) + atalho atual para `Culturas`. Essa discrepância precisa ser alinhada (ver doc `09_ERRORS_AND_RISKS.md`).

## Regras adicionais

- Inputs numéricos mantêm 7 dígitos.  
- Fundo geral é `AppColors.bgSecondary` para reforçar o visual clean.  
- `FloatingActionButton` (Análise) herda `AppColors.primary` e icon `+`.  
- Componentes sempre usam `AppTextStyles` para manter consistência tipográfica.
