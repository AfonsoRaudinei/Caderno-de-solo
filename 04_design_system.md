# 🎨 Design System — iOS/Apple

> Filosofia: design que não chama atenção para si mesmo, mas para os dados do usuário.  
> Profissional, clean, discreto e extremamente funcional.

---

## 🎨 Paleta de Cores

```dart
// core/theme/app_colors.dart

class AppColors {
  // ─── PRIMÁRIAS ─────────────────────────────────────────
  static const primary      = Color(0xFF007AFF); // Azul iOS
  static const primaryDark  = Color(0xFF0051D5); // Azul escuro (gradient)

  // ─── BACKGROUNDS ───────────────────────────────────────
  static const bgPrimary    = Color(0xFFFFFFFF); // Branco
  static const bgSecondary  = Color(0xFFF5F5F7); // Cinza muito claro
  static const bgGradient   = [Color(0xFFF5F5F7), Color(0xFFE5E5E7)];

  // ─── TEXTO ─────────────────────────────────────────────
  static const textPrimary  = Color(0xFF1D1D1F); // Preto suave
  static const textSecond   = Color(0xFF86868B); // Cinza médio
  static const textTertiary = Color(0xFFC7C7CC); // Cinza claro

  // ─── ESTADO ────────────────────────────────────────────
  static const success      = Color(0xFF34C759); // Verde iOS
  static const error        = Color(0xFFFF3B30); // Vermelho iOS
  static const bgSuccess    = Color(0xFFE8F5E9); // Fundo positivo
  static const bgError      = Color(0xFFFFEBEE); // Fundo negativo

  // ─── BORDAS ────────────────────────────────────────────
  static const border       = Color(0xFFD1D1D6); // Borda padrão
  static const borderSoft   = Color(0xFFE5E5E7); // Borda suave

  // ─── NUTRIENTES (cards de calibração) ──────────────────
  static const calcario     = Color(0xFF5AC8FA); // Azul claro
  static const gesso        = Color(0xFFFFCC00); // Amarelo
  static const potassio     = Color(0xFFFF9500); // Laranja
  static const fosforo      = Color(0xFFFF3B30); // Vermelho
  static const enxofre      = Color(0xFF34C759); // Verde
  static const micronut     = Color(0xFFAF52DE); // Roxo
}
```

---

## ✏️ Tipografia

```dart
// core/theme/app_text_styles.dart

class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: '.SF Pro Text',  // iOS nativo
    color: AppColors.textPrimary,
  );

  // Títulos de seção (uppercase, discreto)
  static final sectionLabel = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecond,
  );

  // Texto normal
  static final body = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  // Labels e títulos
  static final label = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Valores destacados (resultados, ROI)
  static final value = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  // Texto grande — resultado principal
  static final headline = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  // Texto pequeno — branding, rodapé
  static final caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
  );
}
```

---

## 🃏 Componentes

### Card padrão
```dart
decoration: BoxDecoration(
  color: Colors.white.withOpacity(0.95),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0,1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0,2)),
  ],
),
// Padding interno: 20px
```

### Input field
```dart
// Normal
border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: AppColors.border),
),
contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),

// Foco
focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(8),
  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
),
// + BoxShadow: 0 0 0 3px rgba(0, 122, 255, 0.1)

// ⚠️ Campos numéricos: maxLength: 7 dígitos
```

### Botão primário
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  ),
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
),
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
```

### Botão secundário (discreto)
```dart
backgroundColor: AppColors.borderSoft,   // #E5E5E7
foregroundColor: AppColors.textSecond,    // #86868B
borderRadius: BorderRadius.circular(8),
```

### Dropdown
```dart
// Usa DropdownButton com visual customizado
// Borda: AppColors.border, radius: 8px
// Ícone: seta SVG customizada
// Padding: 10px
// ⚠️ Preferir dropdown para seleções com 3+ opções
```

---

## 📐 Espaçamento

| Token | Valor | Uso |
|---|---|---|
| `xs` | 4px | Ícone ↔ texto |
| `sm` | 8px | Gap interno card |
| `md` | 12px | Gap entre itens |
| `lg` | 16px | Padding card |
| `xl` | 20px | Padding card principal |
| `xxl` | 24px | Entre seções |
| `section` | 32px | Entre grupos |

---

## 📱 Bottom Navigation Bar

```dart
// 4 tabs — estilo iOS Tab Bar
NavigationBar(
  backgroundColor: Colors.white,
  indicatorColor: AppColors.primary.withOpacity(0.1),
  destinations: [
    NavigationDestination(icon: Icon(Icons.science_outlined),    label: 'Análise'),
    NavigationDestination(icon: Icon(Icons.biotech_outlined),     label: 'Lab'),
    NavigationDestination(icon: Icon(Icons.history_outlined),     label: 'Histórico'),
    NavigationDestination(icon: Icon(Icons.settings_outlined),    label: 'Config'),
  ],
)
```

---

## ⚗️ Tab Bar — Lab (Calibração ↔ Recomendação)

```dart
TabBar(
  tabs: [Tab(text: 'Calibração'), Tab(text: 'Recomendação')],
  labelColor: AppColors.primary,
  unselectedLabelColor: AppColors.textSecond,
  indicatorColor: AppColors.primary,
  indicatorSize: TabBarIndicatorSize.label,
)
// Swipe horizontal: instantâneo via TabBarView
```

---

## 🏷️ Cards de Nutrientes (Calibração)

Cada nutriente tem um card com cor identificadora:

| Nutriente | Cor | Ícone sugerido |
|---|---|---|
| Calcário | `#5AC8FA` azul claro | 🪨 |
| Gesso | `#FFCC00` amarelo | 💎 |
| Potássio | `#FF9500` laranja | ⚡ |
| Fósforo | `#FF3B30` vermelho | 🔴 |
| Enxofre | `#34C759` verde | 🟢 |
| Micronutrientes | `#AF52DE` roxo | 🔬 |

> Enxofre fica agrupado visualmente próximo de Fósforo e Gesso na UI.

---

## 🔖 Citações de Referência (estilo Perplexity)

Na tela de Recomendação, cada dado exibido cita sua fonte:

```
Resultado: Necessidade de Calcário = 2,5 t/ha
─────────────────────────────────────────────
Baseado em: [1] Boletim 100 IAC, [2] Embrapa Cerrados
```

Visual: número sobrescrito clicável → modal com referência completa.

---

## 📐 Regras de Input Numérico

- Máximo: **7 dígitos** em todos os campos numéricos
- Teclado: `TextInputType.number`
- Formatação: `intl` pt-BR (vírgula decimal)
- Validação inline: erro em vermelho `#FF3B30` abaixo do campo

---

*Versão 1.0*
