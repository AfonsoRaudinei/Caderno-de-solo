# SoloForte — Tela "Culturas" · Prompt de Execução Flutter

**Documento:** Especificação completa para implementação  
**Módulo:** 5ª aba da Bottom Navigation Bar  
**Status:** Aprovado para execução  
**Data:** 2026-03-15

---

## 1. CONTEXTO DO PROJETO

App: **SoloForte** — plataforma profissional de análise de solo e recomendação de fertilização  
Stack: Flutter/Dart · Firebase Firestore · Riverpod · Google Project IDX  
Design system: iOS/Apple minimalista (`#007AFF`, SF Pro, bottom nav 5 abas)

---

## 2. O QUE SERÁ CONSTRUÍDO

Uma nova tela de **biblioteca de referência agronômica** acessível pela 5ª aba da bottom bar.

**Objetivo do usuário:** consulta rápida de dados de extração e exportação de nutrientes em soja, filtrada por tipo de fonte (Autor / Cultivar / Tecnologia) com visualização em barras e cálculo de índices percentuais.

**Fluxo de 3 passos:**
```
[1] Escolher tipo de fonte  →  [2] Dropdown de seleção  →  [3] Escolher nutrientes  →  [Resultado]
```

---

## 3. BOTTOM NAVIGATION BAR — ATUALIZAÇÃO

### 3.1 Configuração atual (4 abas)
| Posição | Label | Ícone |
|---------|-------|-------|
| 1 | Análise | `Icons.grid_view_outlined` |
| 2 | Lab | `Icons.science_outlined` |
| 3 | Histórico | `Icons.history_outlined` |
| 4 | Config | `Icons.settings_outlined` |

### 3.2 Nova configuração (5 abas)
| Posição | Label | Ícone Flutter | Cor ativa |
|---------|-------|--------------|-----------|
| 1 | Análise | `Icons.grid_view_outlined` | `#007AFF` |
| 2 | Lab | `Icons.science_outlined` | `#007AFF` |
| 3 | Histórico | `Icons.history_outlined` | `#007AFF` |
| 4 | **Culturas** | `Icons.grass_outlined` | `#007AFF` |
| 5 | Config | `Icons.settings_outlined` | `#007AFF` |

### 3.3 Código de atualização — `main_navigation.dart`

```dart
// Substituir o BottomNavigationBar existente por:
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  type: BottomNavigationBarType.fixed,
  selectedItemColor: const Color(0xFF007AFF),
  unselectedItemColor: const Color(0xFF8E8E93),
  selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
  unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  backgroundColor: Colors.white,
  elevation: 0,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),     label: 'Análise'),
    BottomNavigationBarItem(icon: Icon(Icons.science_outlined),        label: 'Lab'),
    BottomNavigationBarItem(icon: Icon(Icons.history_outlined),        label: 'Histórico'),
    BottomNavigationBarItem(icon: Icon(Icons.grass_outlined),          label: 'Culturas'),
    BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),       label: 'Config'),
  ],
)

// Screens list — adicionar CulturasScreen() na posição 3 (índice 3):
final List<Widget> _screens = [
  const AnaliseScreen(),
  const LabScreen(),
  const HistoricoScreen(),
  const CulturasScreen(),   // ← NOVO
  const ConfigScreen(),
];
```

---

## 4. ARQUIVO DE DADOS — `culturas_data.dart`

Criar em: `lib/data/culturas_data.dart`

### 4.1 Modelos

```dart
// lib/data/culturas_data.dart

class NutrientRecord {
  final double N, P, K, Ca, Mg, S, Cu, Fe, Mn, Zn, B, Mo, Co, Ni, Se;

  const NutrientRecord({
    required this.N,  required this.P,  required this.K,
    required this.Ca, required this.Mg, required this.S,
    this.Cu = 0, this.Fe = 0, this.Mn = 0, this.Zn = 0,
    this.B = 0,  this.Mo = 0, this.Co = 0, this.Ni = 0, this.Se = 0,
  });

  double get(String key) => switch (key) {
    'N'  => N,  'P'  => P,  'K'  => K,
    'Ca' => Ca, 'Mg' => Mg, 'S'  => S,
    'Cu' => Cu, 'Fe' => Fe, 'Mn' => Mn,
    'Zn' => Zn, 'B'  => B,  'Mo' => Mo,
    'Co' => Co, 'Ni' => Ni, 'Se' => Se,
    _ => 0.0,
  };
}

class SourceEntry {
  final NutrientRecord exportacao;
  final NutrientRecord extracao;
  const SourceEntry({required this.exportacao, required this.extracao});
}

enum SourceType { autor, cultivar, tecnologia }
```

### 4.2 Constantes de nutrientes para UI

```dart
class NutrientMeta {
  final String key;
  final String fullName;
  final String unit;       // 'kg/t' para macros, 'g/t' para micros
  final Color color;
  final bool isMacro;

  const NutrientMeta({
    required this.key, required this.fullName,
    required this.unit, required this.color, required this.isMacro,
  });
}

const List<NutrientMeta> kNutrients = [
  NutrientMeta(key:'N',  fullName:'Nitrogênio', unit:'kg/t', color:Color(0xFF007AFF), isMacro:true),
  NutrientMeta(key:'P',  fullName:'Fósforo',    unit:'kg/t', color:Color(0xFF34C759), isMacro:true),
  NutrientMeta(key:'K',  fullName:'Potássio',   unit:'kg/t', color:Color(0xFFFF9500), isMacro:true),
  NutrientMeta(key:'Ca', fullName:'Cálcio',     unit:'kg/t', color:Color(0xFFAF52DE), isMacro:true),
  NutrientMeta(key:'Mg', fullName:'Magnésio',   unit:'kg/t', color:Color(0xFFFF2D55), isMacro:true),
  NutrientMeta(key:'S',  fullName:'Enxofre',    unit:'kg/t', color:Color(0xFF5AC8FA), isMacro:true),
  NutrientMeta(key:'Fe', fullName:'Ferro',      unit:'g/t',  color:Color(0xFF8E6C3D), isMacro:false),
  NutrientMeta(key:'Zn', fullName:'Zinco',      unit:'g/t',  color:Color(0xFF636366), isMacro:false),
  NutrientMeta(key:'Mn', fullName:'Manganês',   unit:'g/t',  color:Color(0xFF1C7A4A), isMacro:false),
  NutrientMeta(key:'B',  fullName:'Boro',       unit:'g/t',  color:Color(0xFFC0392B), isMacro:false),
];

// Valores máximos para escala das barras
const Map<String, double> kMaxValues = {
  'N': 200, 'P': 40,   'K': 130, 'Ca': 65,
  'Mg': 20, 'S': 30,   'Fe': 1200, 'Zn': 200,
  'Mn': 320,'B': 200,
};
```

### 4.3 Dataset completo

```dart
// ── AUTORES ───────────────────────────────────────────────────
const Map<String, SourceEntry> kAutores = {
  'Araújo (2023)': SourceEntry(
    exportacao: NutrientRecord(N:41.36,P:3.40,K:9.93,Ca:0.60,Mg:0.86,S:1.28,Cu:4.32,Fe:8.93,Zn:15.64,Mn:4.28,B:12.38),
    extracao:   NutrientRecord(N:59.94,P:5.23,K:18.74,Ca:2.39,Mg:2.70,S:2.98,Cu:8.63,Fe:44.67,Zn:31.28,Mn:21.41,B:32.58),
  ),
  'Santos et al. (2008)': SourceEntry(
    exportacao: NutrientRecord(N:46.62,P:2.61,K:10.52,Ca:0.74,Mg:0.75,S:0.89,Cu:27.39,Fe:29.81,Zn:27.28,Mn:5.86,B:9.11),
    extracao:   NutrientRecord(N:67.57,P:4.02,K:19.84,Ca:3.30,Mg:2.81,S:2.06,Cu:52.98,Fe:149.08,Zn:53.38,Mn:30.85,B:23.09),
  ),
  'EMBRAPA': SourceEntry(
    exportacao: NutrientRecord(N:83.00,P:8.40,K:25.00,Ca:13.50,Mg:7.30,S:9.00),
    extracao:   NutrientRecord(N:51.00,P:1.00,K:2.00,Ca:3.10,Mg:2.00,S:5.00,Cu:1,Fe:7,Zn:4,Mn:3,B:2),
  ),
  'Tanaka et al. (1994)': SourceEntry(
    exportacao: NutrientRecord(N:82.00,P:7.50,K:24.00,Ca:12.00,Mg:7.20,S:15.00),
    extracao:   NutrientRecord(N:51.00,P:5.00,K:17.00,Ca:2.80,Mg:2.00,S:5.00,Fe:218),
  ),
  'Bataglia & Mascarenhas (1977)': SourceEntry(
    exportacao: NutrientRecord(N:76.00,P:5.70,K:32.00,Ca:1.90,Mg:2.90,S:3.10,Cu:26,Fe:46,Zn:61,Mn:13,B:77),
    extracao:   NutrientRecord(N:64.00,P:4.70,K:18.00,Ca:11.60,Mg:6.70,Cu:14,Fe:115,Zn:43,Mn:43,B:24),
  ),
  'Borkert (1986)': SourceEntry(
    exportacao: NutrientRecord(N:82.00,P:7.50,K:24.50,Ca:11.80,Mg:7.40,S:15.00),
    extracao:   NutrientRecord(N:51.00,P:7.60,K:17.00,Ca:3.30,Mg:3.50,S:5.00),
  ),
  'Cordeiro et al. (1977)': SourceEntry(
    exportacao: NutrientRecord(N:77.40,P:6.00,K:32.00,Ca:13.40,Mg:4.00,S:8.00),
    extracao:   NutrientRecord(N:64.40,P:5.00,K:16.50,Ca:2.90,Mg:2.40,S:8.00),
  ),
  'Darwich (1993)': SourceEntry(
    exportacao: NutrientRecord(N:82.00,P:1.00,K:4.00,Ca:7.00,Mg:7.80,S:7.00),
    extracao:   NutrientRecord(N:58.80,P:5.20,K:18.70,Ca:1.90,Mg:2.10,S:3.00),
  ),
  'Kurihara et al. (2013)': SourceEntry(
    exportacao: NutrientRecord(N:42.33,P:3.83,K:7.29,Ca:0.61,Mg:0.54,S:2.78,Cu:13.48,Fe:15.51,Zn:31.66,Mn:5.39,B:10.07),
    extracao:   NutrientRecord(N:61.35,P:5.89,K:13.76,Ca:2.13,Mg:2.39,S:5.96,Cu:26.92,Fe:78.00,Zn:63.15,Mn:27.10,B:26.23),
  ),
};

// ── TECNOLOGIAS ───────────────────────────────────────────────
const Map<String, SourceEntry> kTecnologias = {
  'Enlist': SourceEntry(
    exportacao: NutrientRecord(N:53.9,P:9.3,K:19.1,Ca:2.2,Mg:2.5,S:6.7,Cu:10.9,Fe:122.3,Zn:46.5,Mn:14.1,B:37.3),
    extracao:   NutrientRecord(N:142.9,P:31.9,K:120.8,Ca:35.8,Mg:13.6,S:17.9,Cu:37.5,Fe:726.3,Zn:159.7,Mn:195.4,B:163.9),
  ),
  'Xtend': SourceEntry(
    exportacao: NutrientRecord(N:55.1,P:10.9,K:19.6,Ca:2.3,Mg:2.5,S:8.6,Cu:12.7,Fe:246.7,Zn:44.8,Mn:14.3,B:38.7),
    extracao:   NutrientRecord(N:179.9,P:36.4,K:127.6,Ca:61.1,Mg:18.9,S:27.3,Cu:42.6,Fe:1106.9,Zn:178.5,Mn:309.9,B:179.8),
  ),
  'Roundup Ready': SourceEntry(
    exportacao: NutrientRecord(N:55.6,P:9.3,K:20.6,Ca:2.1,Mg:2.6,S:8.3,Cu:11.0,Fe:123.1,Zn:43.8,Mn:15.7,B:34.6),
    extracao:   NutrientRecord(N:145.8,P:29.4,K:106.9,Ca:43.5,Mg:14.7,S:22.2,Cu:32.8,Fe:673.9,Zn:140.1,Mn:198.4,B:160.1),
  ),
};

// ── CULTIVARES (amostra — dataset completo em culturas_data.dart) ──
const Map<String, SourceEntry> kCultivares = {
  'AS3595i2x': SourceEntry(
    exportacao: NutrientRecord(N:66.9,P:5.7,K:19.2,Ca:3.0,Mg:3.3,S:3.1,Cu:1.0,Fe:34.5,Zn:35.1,Mn:22.7,B:35.4),
    extracao:   NutrientRecord(N:96.96,P:8.77,K:36.23,Ca:12.0,Mg:10.31,S:7.21,Cu:2.0,Fe:172.5,Zn:70.2,Mn:113.5,B:93.16),
  ),
  'ADV4681 Ipro SR1': SourceEntry(
    exportacao: NutrientRecord(N:62.9,P:5.5,K:19.3,Ca:2.5,Mg:3.0,S:3.0,Cu:8.1,Fe:29.2,Zn:49.0,Mn:24.4,B:35.0),
    extracao:   NutrientRecord(N:91.16,P:8.46,K:36.42,Ca:10.0,Mg:9.38,S:6.98,Cu:16.2,Fe:146.0,Zn:98.0,Mn:122.0,B:92.11),
  ),
  'CZ37B39 I2X': SourceEntry(
    exportacao: NutrientRecord(N:63.6,P:5.1,K:18.1,Ca:2.6,Mg:2.9,S:3.3,Cu:9.0,Fe:41.6,Zn:29.4,Mn:22.9,B:35.5),
    extracao:   NutrientRecord(N:92.17,P:7.85,K:34.15,Ca:10.4,Mg:9.06,S:7.67,Cu:18.0,Fe:208.0,Zn:58.8,Mn:114.5,B:93.42),
  ),
  'DM 74K75': SourceEntry(
    exportacao: NutrientRecord(N:63.2,P:4.7,K:19.2,Ca:2.2,Mg:2.4,S:3.0,Cu:7.6,Fe:36.7,Zn:26.7,Mn:19.8,B:35.3),
    extracao:   NutrientRecord(N:91.59,P:7.23,K:36.23,Ca:8.8,Mg:7.5,S:6.98,Cu:15.2,Fe:183.5,Zn:53.4,Mn:99.0,B:92.89),
  ),
  'Desafio RR BM1': SourceEntry(
    exportacao: NutrientRecord(N:57.8,P:5.5,K:22.3,Ca:2.3,Mg:3.0,S:3.1,Cu:7.3,Fe:17.3,Zn:48.0,Mn:27.7,B:31.9),
    extracao:   NutrientRecord(N:83.77,P:8.46,K:42.08,Ca:9.2,Mg:9.38,S:7.21,Cu:14.6,Fe:86.5,Zn:96.0,Mn:138.5,B:83.95),
  ),
  'Juruena Ipro SR3': SourceEntry(
    exportacao: NutrientRecord(N:58.0,P:5.8,K:21.8,Ca:2.5,Mg:2.6,S:2.9,Cu:7.4,Fe:15.1,Zn:44.9,Mn:29.9,B:39.6),
    extracao:   NutrientRecord(N:84.06,P:8.92,K:41.13,Ca:10.0,Mg:8.13,S:6.74,Cu:14.8,Fe:75.5,Zn:89.8,Mn:149.5,B:104.21),
  ),
  'M 6430 XTD': SourceEntry(
    exportacao: NutrientRecord(N:62.4,P:4.8,K:17.3,Ca:3.0,Mg:3.0,S:3.1,Cu:7.7,Fe:73.4,Zn:23.6,Mn:22.4,B:26.6),
    extracao:   NutrientRecord(N:90.43,P:7.38,K:32.64,Ca:12.0,Mg:9.38,S:7.21,Cu:15.4,Fe:367.0,Zn:47.2,Mn:112.0,B:70.0),
  ),
  'NEOGEN 680': SourceEntry(
    exportacao: NutrientRecord(N:61.3,P:5.9,K:18.8,Ca:2.4,Mg:2.4,S:3.2,Cu:1.0,Fe:4.6,Zn:29.3,Mn:18.7,B:34.9),
    extracao:   NutrientRecord(N:88.84,P:9.08,K:35.47,Ca:9.6,Mg:7.5,S:7.44,Cu:2.0,Fe:23.0,Zn:58.6,Mn:93.5,B:91.84),
  ),
  'NEOGEN 770': SourceEntry(
    exportacao: NutrientRecord(N:59.3,P:5.2,K:16.3,Ca:2.7,Mg:2.7,S:3.0,Cu:9.4,Fe:51.0,Zn:32.2,Mn:21.2,B:38.0),
    extracao:   NutrientRecord(N:85.94,P:8.0,K:30.75,Ca:10.8,Mg:8.44,S:6.98,Cu:18.8,Fe:255.0,Zn:64.4,Mn:106.0,B:100.0),
  ),
};
```

---

## 5. PROVIDER — `culturas_provider.dart`

Criar em: `lib/features/culturas/providers/culturas_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Tipo de dado exibido ──────────────────────────────────────
enum DataMode { exportacao, extracao, percentual }

// ── Estado da tela ────────────────────────────────────────────
class CulturasState {
  final SourceType? sourceType;
  final String? selectedSource;
  final List<String> selectedNutrients;
  final DataMode dataMode;

  const CulturasState({
    this.sourceType,
    this.selectedSource,
    this.selectedNutrients = const ['N', 'P', 'K'],
    this.dataMode = DataMode.exportacao,
  });

  CulturasState copyWith({
    SourceType? sourceType,
    String? selectedSource,
    List<String>? selectedNutrients,
    DataMode? dataMode,
    bool clearSource = false,
  }) => CulturasState(
    sourceType:         sourceType ?? this.sourceType,
    selectedSource:     clearSource ? null : (selectedSource ?? this.selectedSource),
    selectedNutrients:  selectedNutrients ?? this.selectedNutrients,
    dataMode:           dataMode ?? this.dataMode,
  );
}

// ── Notifier ──────────────────────────────────────────────────
class CulturasNotifier extends StateNotifier<CulturasState> {
  CulturasNotifier() : super(const CulturasState());

  void setSourceType(SourceType type) {
    state = state.copyWith(sourceType: type, clearSource: true);
  }

  void setSelectedSource(String name) {
    state = state.copyWith(selectedSource: name);
  }

  void toggleNutrient(String key) {
    final current = List<String>.from(state.selectedNutrients);
    if (current.contains(key)) {
      if (current.length == 1) return; // mínimo 1
      current.remove(key);
    } else {
      if (current.length >= 3) current.removeAt(0); // máximo 3, FIFO
      current.add(key);
    }
    state = state.copyWith(selectedNutrients: current);
  }

  void setDataMode(DataMode mode) {
    state = state.copyWith(dataMode: mode);
  }
}

// ── Providers ─────────────────────────────────────────────────
final culturasProvider =
    StateNotifierProvider<CulturasNotifier, CulturasState>(
  (ref) => CulturasNotifier(),
);

// Retorna os nomes disponíveis para a fonte selecionada
final sourcesListProvider = Provider<List<String>>((ref) {
  final type = ref.watch(culturasProvider).sourceType;
  return switch (type) {
    SourceType.autor      => kAutores.keys.toList(),
    SourceType.tecnologia => kTecnologias.keys.toList(),
    SourceType.cultivar   => kCultivares.keys.toList(),
    null                  => [],
  };
});

// Retorna o SourceEntry da seleção atual (null se incompleto)
final currentEntryProvider = Provider<SourceEntry?>((ref) {
  final state = ref.watch(culturasProvider);
  if (state.sourceType == null || state.selectedSource == null) return null;
  return switch (state.sourceType!) {
    SourceType.autor      => kAutores[state.selectedSource],
    SourceType.tecnologia => kTecnologias[state.selectedSource],
    SourceType.cultivar   => kCultivares[state.selectedSource],
  };
});
```

---

## 6. TELA PRINCIPAL — `culturas_screen.dart`

Criar em: `lib/features/culturas/screens/culturas_screen.dart`

### 6.1 Estrutura completa

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/culturas_provider.dart';
import '../widgets/source_type_pills.dart';
import '../widgets/source_dropdown.dart';
import '../widgets/nutrient_selector.dart';
import '../widgets/result_card.dart';

class CulturasScreen extends ConsumerWidget {
  const CulturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(culturasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Culturas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passo 1 — Tipo de fonte
            _SectionLabel('Tipo de fonte'),
            const SizedBox(height: 8),
            const SourceTypePills(),
            const SizedBox(height: 20),

            // Passo 2 — Dropdown (aparece após tipo de fonte)
            if (state.sourceType != null) ...[
              _SectionLabel(_dropdownLabel(state.sourceType!)),
              const SizedBox(height: 8),
              const SourceDropdown(),
              const SizedBox(height: 20),
            ],

            // Passo 3 — Seletor de nutrientes (aparece após fonte selecionada)
            if (state.selectedSource != null) ...[
              _SectionLabel('Nutrientes (até 3)'),
              const SizedBox(height: 8),
              const NutrientSelector(),
              const SizedBox(height: 20),
              const ResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  String _dropdownLabel(SourceType type) => switch (type) {
    SourceType.autor      => 'Selecionar Autor',
    SourceType.cultivar   => 'Selecionar Cultivar',
    SourceType.tecnologia => 'Selecionar Tecnologia',
  };
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: Color(0xFF86868B), letterSpacing: 0.5,
    ),
  );
}
```

---

## 7. WIDGETS

### 7.1 `source_type_pills.dart`

```dart
// lib/features/culturas/widgets/source_type_pills.dart

class SourceTypePills extends ConsumerWidget {
  const SourceTypePills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(culturasProvider).sourceType;

    return Row(
      children: SourceType.values.map((type) {
        final isSelected = current == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: type != SourceType.tecnologia ? 8 : 0),
            child: GestureDetector(
              onTap: () => ref.read(culturasProvider.notifier).setSourceType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconFor(type), size: 16,
                      color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF86868B)),
                    const SizedBox(width: 6),
                    Text(_labelFor(type),
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF86868B),
                      )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(SourceType t) => switch (t) {
    SourceType.autor      => Icons.people_outline,
    SourceType.cultivar   => Icons.grass_outlined,
    SourceType.tecnologia => Icons.wb_sunny_outlined,
  };

  String _labelFor(SourceType t) => switch (t) {
    SourceType.autor      => 'Autor',
    SourceType.cultivar   => 'Cultivar',
    SourceType.tecnologia => 'Tecnologia',
  };
}
```

### 7.2 `source_dropdown.dart`

```dart
// lib/features/culturas/widgets/source_dropdown.dart

class SourceDropdown extends ConsumerWidget {
  const SourceDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources   = ref.watch(sourcesListProvider);
    final selected  = ref.watch(culturasProvider).selectedSource;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected != null ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Escolher...', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 14)),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF86868B)),
          borderRadius: BorderRadius.circular(12),
          items: sources.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s, style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F))),
          )).toList(),
          onChanged: (v) {
            if (v != null) ref.read(culturasProvider.notifier).setSelectedSource(v);
          },
        ),
      ),
    );
  }
}
```

### 7.3 `nutrient_selector.dart`

```dart
// lib/features/culturas/widgets/nutrient_selector.dart

class NutrientSelector extends ConsumerWidget {
  const NutrientSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(culturasProvider).selectedNutrients;

    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: kNutrients.map((n) {
        final isSel = selected.contains(n.key);
        return GestureDetector(
          onTap: () => ref.read(culturasProvider.notifier).toggleNutrient(n.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSel ? n.color : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel ? n.color : const Color(0xFFE5E5EA),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n.key,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : const Color(0xFF86868B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

### 7.4 `result_card.dart` — card com toggle 3 opções + barras

```dart
// lib/features/culturas/widgets/result_card.dart

class ResultCard extends ConsumerWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(culturasProvider);
    final entry   = ref.watch(currentEntryProvider);
    if (entry == null) return const SizedBox.shrink();

    final tagColor = switch (state.sourceType!) {
      SourceType.autor      => const Color(0xFF007AFF),
      SourceType.cultivar   => const Color(0xFF34C759),
      SourceType.tecnologia => const Color(0xFFFF9500),
    };
    final tagLabel = switch (state.sourceType!) {
      SourceType.autor      => 'Autor',
      SourceType.cultivar   => 'Cultivar',
      SourceType.tecnologia => 'Tecnologia',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(state.selectedSource!,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(tagLabel,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),

          // Toggle 3 opções
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _DataModeToggle(),
          ),

          // Barras
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: state.dataMode == DataMode.percentual
                ? _PercentualBars(entry: entry, nutrients: state.selectedNutrients)
                : _SingleBars(entry: entry, nutrients: state.selectedNutrients, mode: state.dataMode),
          ),
        ],
      ),
    );
  }
}

// ── Toggle ────────────────────────────────────────────────────
class _DataModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(culturasProvider).dataMode;
    return Container(
      height: 34,
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: DataMode.values.map((m) {
          final isActive = mode == m;
          final label = switch (m) {
            DataMode.exportacao  => 'Exportação',
            DataMode.extracao    => 'Extração',
            DataMode.percentual  => '%',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(culturasProvider.notifier).setDataMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                    ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0,1))]
                    : null,
                ),
                alignment: Alignment.center,
                child: Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? const Color(0xFF1D1D1F) : const Color(0xFF86868B),
                  )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Barras simples (Exportação ou Extração) ───────────────────
class _SingleBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  final DataMode mode;
  const _SingleBars({required this.entry, required this.nutrients, required this.mode});

  @override
  Widget build(BuildContext context) {
    final record = mode == DataMode.exportacao ? entry.exportacao : entry.extracao;
    return Column(
      children: nutrients.map((key) {
        final meta  = kNutrients.firstWhere((n) => n.key == key);
        final value = record.get(key);
        final pct   = (value / (kMaxValues[key] ?? 100)).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${meta.fullName} ($key)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1D1D1F))),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: value.toStringAsFixed(value < 10 ? 2 : 1),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F))),
                    TextSpan(text: ' ${meta.unit}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
                  ])),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF0F0F5),
                    valueColor: AlwaysStoppedAnimation(meta.color),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Barras percentuais (Exp% e Ext% lado a lado) ─────────────
//
// Exp% = (Exportação ÷ Extração) × 100
//        → % do absorvido que saiu nos grãos
//
// Ext% = (Extração ÷ Exportação) × 100
//        → quanto a planta absorveu além do que exportou
//
class _PercentualBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  const _PercentualBars({required this.entry, required this.nutrients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legenda
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _LegendDot(color: const Color(0xFF34C759), label: 'Exp% = exportação ÷ extração'),
              const SizedBox(width: 12),
              _LegendDot(color: const Color(0xFF007AFF), label: 'Ext% = extração ÷ exportação'),
            ],
          ),
        ),
        // Nutrientes
        ...nutrients.map((key) {
          final meta  = kNutrients.firstWhere((n) => n.key == key);
          final expV  = entry.exportacao.get(key);
          final extV  = entry.extracao.get(key);
          final expPct = extV > 0 ? (expV / extV * 100).round() : 0;
          final extPct = expV > 0 ? (extV / expV * 100).round() : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${meta.fullName} ($key)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1D1D1F))),
                    Text('$expV / $extV ${meta.unit}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                  ],
                ),
                const SizedBox(height: 6),
                _PctBarRow(label: 'Exp%', pct: expPct, color: const Color(0xFF34C759)),
                const SizedBox(height: 4),
                _PctBarRow(label: 'Ext%', pct: extPct, color: const Color(0xFF007AFF), capAt: 300),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PctBarRow extends StatelessWidget {
  final String label;
  final int pct;
  final Color color;
  final int capAt;
  const _PctBarRow({required this.label, required this.pct, required this.color, this.capAt = 100});

  @override
  Widget build(BuildContext context) {
    final barFraction = (pct / capAt).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 34,
          child: Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: barFraction),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v, minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F5),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        SizedBox(width: 38,
          child: Text('$pct%', textAlign: TextAlign.right,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
    ],
  );
}
```

---

## 8. ESTRUTURA DE ARQUIVOS

```
lib/
├── data/
│   └── culturas_data.dart              ← modelos + dataset completo
│
└── features/
    └── culturas/
        ├── providers/
        │   └── culturas_provider.dart  ← estado Riverpod
        ├── screens/
        │   └── culturas_screen.dart    ← tela principal
        └── widgets/
            ├── source_type_pills.dart  ← pills Autor/Cultivar/Tecnologia
            ├── source_dropdown.dart    ← dropdown de seleção
            ├── nutrient_selector.dart  ← grid 5×2 de nutrientes
            └── result_card.dart        ← card com toggle + barras
```

---

## 9. ORDEM DE EXECUÇÃO

| # | Passo | Arquivo | Dependência |
|---|-------|---------|-------------|
| 1 | Criar modelos e dataset | `culturas_data.dart` | nenhuma |
| 2 | Criar provider | `culturas_provider.dart` | step 1 |
| 3 | Criar widgets (ordem) | `source_type_pills` → `source_dropdown` → `nutrient_selector` → `result_card` | step 2 |
| 4 | Criar tela | `culturas_screen.dart` | steps 2–3 |
| 5 | Registrar na bottom bar | `main_navigation.dart` | step 4 |

---

## 10. REGRAS DE NEGÓCIO

| Regra | Detalhe |
|-------|---------|
| Nutrientes simultâneos | Máximo 3. Ao selecionar o 4º, o mais antigo é removido (FIFO) |
| Nutrientes mínimos | Não permite deselecionar se só há 1 ativo |
| Exp% fórmula | `(exportacao ÷ extracao) × 100` — % do absorvido que saiu nos grãos |
| Ext% fórmula | `(extracao ÷ exportacao) × 100` — quanto absorveu além do exportado |
| Barra Ext% escala | Capped em 300% para não colapsar a barra (valores podem ser > 100%) |
| Valor 0 no dataset | Dado indisponível na literatura — barra não renderiza |
| Inputs numéricos | Máximo 7 dígitos (padrão SoloForte) |

---

## 11. NOTAS TÉCNICAS

- Não usar `ListView` dentro de `SingleChildScrollView` — usar `Column` + `shrinkWrap: true` nos grids
- `TweenAnimationBuilder` nas barras garante animação suave ao trocar nutriente ou modo
- `AnimatedContainer` nas pills e botões do toggle garante transição de cor fluida
- O `DropdownButton` nativo do Flutter é suficiente — não requer package externo
- Dataset completo (47 cultivares, 11 autores, 3 tecnologias) está no arquivo `culturas_data.dart` gerado previamente (`nutrientes_soja_dados.dart`)

---

*Documento gerado para execução direta no Google Project IDX · SoloForte v1.0*
