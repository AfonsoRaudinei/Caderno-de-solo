# Instrução — Templates de Laboratórios: IBRA, Exata Brasil, MB Agronegócios

> Pasta raiz do projeto: `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/`
> Pasta de templates existente: `Analise/lib/data/lab_templates/`
> O template Sellar já existe. Siga o mesmo padrão de estrutura.
> Regra: pare apenas se flutter analyze retornar erros ou arquivo referenciado não existir.

---

## Contexto — O que já existe (Sellar como modelo)

```
lib/data/lab_templates/
  sellar_template.dart          ← modelo a seguir
  sellar_import_service.dart    ← modelo a seguir
lib/domain/entities/
  lab_info.dart                 ← já existe, reutilizar
```

Leia `sellar_template.dart` e `sellar_import_service.dart` antes de criar qualquer arquivo.
Use exatamente a mesma estrutura — só mude os valores do mapeamento.

---

## Laboratório 1 — Exata Brasil

**Identificação no PDF:** "Exata Brasil" ou "EXATA BRASIL" ou "exatabrasil.com.br"
**Sistema:** Software Ultra Lims
**Arquivos de referência lidos:** Relatório 16723.2024 e 17259.2025

### Particularidades do formato Exata Brasil

- Resultados em **múltiplas tabelas por página** — cada tabela é um grupo de parâmetros
- Unidades de K: vem em **mg/dm³** (coluna `K (NH4Cl)`) E em **cmolc/dm³** (coluna `K`) — usar sempre `K (NH4Cl)` em mg/dm³ e converter: `K_cmolc = K_mgdm3 / 391`
- Campo `Ca + Mg` existe mas é derivado — ignorar, calcular do Ca e Mg individuais
- `M.O.` em g/dm³ (não dag/kg como Sellar) — registrar a unidade no template
- `C.O.` em g/dm³
- Micronutrientes vêm em **dois extratores**: Mehlich (meh) e DTPA — guardar ambos
  - `cu_meh`, `fe_meh`, `mn_meh`, `zn_meh` → extrator Mehlich
  - `cu_dtpa`, `fe_dtpa`, `mn_dtpa`, `zn_dtpa` → extrator DTPA
  - No campo canônico `cu`, `fe`, `mn`, `zn` → usar o valor DTPA como principal
- Campo `P (rem)` = `pRem` — pode ser `-` (ausente) → tratar como null
- Campo `Na` em cmolc/dm³

### Mapeamento Exata Brasil → canônico

```dart
const exataBrasilFieldMap = {
  // Identificação (vem do cabeçalho, não da linha de dados)
  'descricaoAmostra':  'talhao',
  'amostra':           'numeroAmostra',
  'profundidade':      'profundidade',

  // pH
  'pH (CaCl2)':        'phCaCl2',
  'pH (SMP)':          'phSmp',

  // Matéria Orgânica — unidade g/dm³ (converter ÷10 para dag/kg)
  'M.O.':              'materiaOrganica',   // ÷ 10 ao importar
  'C.O.':              'carbonoOrganico',   // ÷ 10 ao importar

  // Fósforo
  'P (meh)':           'pMehlich',
  'P (res)':           'pResina',
  'P (rem)':           'pRem',

  // Enxofre
  'S':                 's020',

  // Macronutrientes
  'K (NH4Cl)':         'k_mgdm3',   // intermediário — converter para cmolc/dm³ ÷ 391
  'Ca':                'ca',
  'Mg':                'mg',
  'Al':                'al',
  'H + Al':            'hMaisAl',
  'Na':                'na',

  // Micronutrientes — DTPA como principal
  'Cu (DTPA)':         'cu',
  'Fe (DTPA)':         'fe',
  'Mn (DTPA)':         'mn',
  'Zn (DTPA)':         'zn',
  'B':                 'b',

  // Composição Física
  'Argila':            'argila',
  'Silte':             'silte',
  'Areia':             'areiaTotal',
};
```

### Conversões obrigatórias no ExataBrasilImportService

```dart
// K: mg/dm³ → cmolc/dm³
double kCmolc = (kMgDm3 ?? 0) / 391.0;

// M.O. e C.O.: g/dm³ → dag/kg (÷ 10)
double moDagKg = (moGdm3 ?? 0) / 10.0;
double coDagKg = (coGdm3 ?? 0) / 10.0;
```

### Arquivos a criar

```
lib/data/lab_templates/
  exata_brasil_template.dart
  exata_brasil_import_service.dart

assets/lab_data/
  exata_brasil_16723_2024.json    ← dados das 12 amostras SBA24.99401–99412
  exata_brasil_17259_2025.json    ← dados das 28 amostras SBA25.147266–147293
```

### JSON exata_brasil_16723_2024.json — estrutura esperada

```json
{
  "fonte": "Exata Brasil",
  "relatorio": "16723.2024.V0.U",
  "dataEmissao": "2024-08-14",
  "proprietario": "JOSE AUGUSTO MIRANDA",
  "propriedade": "SANTA MARIA - ROSALANDIA/TO",
  "laboratorio": "Exata Brasil Unidade BA",
  "amostras": [
    {
      "numeroAmostra": "SBA24.99407",
      "talhao": "RA 04",
      "profundidade": "0-10",
      "phCaCl2": 5.05,
      "materiaOrganica": 26.41,
      "carbonoOrganico": 15.32,
      "pMehlich": 43.14,
      "pResina": 65.30,
      "pRem": 19.24,
      "s020": 12.60,
      "k_mgdm3": 43.18,
      "ca": 2.37,
      "mg": 0.98,
      "al": 0.03,
      "hMaisAl": 4.05,
      "na": 1.00,
      "b": 0.34,
      "cu": 1.62,
      "fe": 15.03,
      "mn": 8.84,
      "zn": 0.71,
      "argila": 563.5,
      "silte": 72.5,
      "areiaTotal": 364.0
    }
    // ... demais amostras
  ]
}
```

Preencha todas as 12 amostras do relatório 16723.2024 com os valores exatos dos PDFs.
Preencha todas as 28 amostras do relatório 17259.2025.

---

## Laboratório 2 — IBRA (Instituto Brasileiro de Análises)

**Identificação no PDF:** "INSTITUTO BRASILEIRO DE ANÁLISES" ou "ibra.com.br" ou "IBRA"
**Contratante nos PDFs:** Agrofarm — Produtos Agroquímicos Ltda.
**Arquivo de referência:** O.S. 237526, FAZ. ESTRELA, 14 amostras (257056–257069)

### Particularidades do formato IBRA

- Todas as amostras em **uma única tabela horizontal** por página
- Unidades de K, Ca, Mg em **mmolc/dm³** — converter para cmolc/dm³ ÷ 10
- `P` = Fósforo Resina (extrator IAC) → mapear para `pResina`
- `P Rem` = Fósforo Remanescente → mapear para `pRem`
- **Não tem P Mehlich** neste laudo — `pMehlich` = null
- `M.O.` em g/dm³ → converter ÷ 10 para dag/kg
- `COT` (Carbono Orgânico Total) em g/dm³ → converter ÷ 10
- Micronutrientes: B (ME SOLO 03), Cu/Fe/Mn/Zn (DTPA — IAC)
- Campo `H°` (Hidrogênio) existe separado de `H° + Al³` — registrar ambos
- `Na na CTC`, `Ca na CTC`, `Mg na CTC`, `K na CTC` são derivados calculados — ignorar no import

### Conversões obrigatórias no IbraImportService

```dart
// K, Ca, Mg, Al, H+Al: mmolc/dm³ → cmolc/dm³ (÷ 10)
double kCmolc   = (kMmolc   ?? 0) / 10.0;
double caCmolc  = (caMmolc  ?? 0) / 10.0;
double mgCmolc  = (mgMmolc  ?? 0) / 10.0;
double alCmolc  = (alMmolc  ?? 0) / 10.0;
double halCmolc = (halMmolc ?? 0) / 10.0;

// M.O. e COT: g/dm³ → dag/kg (÷ 10)
double moDagKg = (moGdm3 ?? 0) / 10.0;
double coDagKg = (cotGdm3 ?? 0) / 10.0;
```

### Mapeamento IBRA → canônico

```dart
const ibraFieldMap = {
  // pH
  'pH (CaCl2)':   'phCaCl2',
  'pH (SMP)':     'phSmp',

  // Matéria Orgânica
  'M.O.':         'materiaOrganica',   // ÷ 10
  'COT':          'carbonoOrganico',   // ÷ 10

  // Fósforo
  'P':            'pResina',           // extrator IAC = Resina
  'P Rem':        'pRem',

  // Enxofre
  'S':            's020',

  // Macronutrientes — todos em mmolc/dm³, converter ÷ 10
  'K':            'k',
  'Ca':           'ca',
  'Mg':           'mg',
  'Al³':          'al',
  'H° + Al³':     'hMaisAl',
  'Na':           'na',

  // Micronutrientes
  'B':            'b',
  'Cu':           'cu',
  'Fe':           'fe',
  'Mn':           'mn',
  'Zn':           'zn',

  // Composição Física
  'Argila':       'argila',
  'Silte':        'silte',
  'Areia Total':  'areiaTotal',
};
```

### Arquivos a criar

```
lib/data/lab_templates/
  ibra_template.dart
  ibra_import_service.dart

assets/lab_data/
  ibra_237526_2025.json    ← 14 amostras 257056–257069
```

### JSON ibra_237526_2025.json — valores das 14 amostras

Preencha com os valores exatos do PDF O.S. 237526:

| Nº LAB | Talhão | Prof | pH CaCl2 | pH SMP | P(Resina) | P Rem | M.O. | COT | K(mmolc) | Ca(mmolc) | Mg(mmolc) | Al | H+Al | S | B | Cu | Fe | Mn | Zn | Argila | Silte | Areia |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 257056 | LT-01 | 0-20 | 5.8 | 6.79 | 18 | 37.58 | 22 | 13 | 0.8 | 29 | 12 | 0 | 18 | 3 | 0.4 | 0.4 | 20 | 0.6 | 0.5 | 98 | 74 | 828 |
| 257057 | LT-02 | 0-20 | 5.4 | 6.26 | 19 | 33.25 | 32 | 19 | 1.3 | 28 | 10 | 0 | 32 | 3 | 0.64 | 0.5 | 23 | 5.0 | 0.8 | 123 | 96 | 781 |
| 257058 | LT-3A | 0-20 | 5.6 | 6.70 | 16 | 38.23 | 32 | 19 | 1.7 | 30 | 14 | 0 | 20 | 3 | 0.46 | 0.3 | 18 | 3.8 | 1.5 | 167 | 66 | 767 |
| 257059 | LT-3B | 0-20 | 5.1 | 6.09 | 16 | 30.93 | 28 | 16 | 2.2 | 21 | 12 | 0 | 38 | 3 | 0.46 | 0.3 | 33 | 1.8 | 0.6 | 126 | 68 | 806 |
| 257060 | LT-4A | 0-20 | 5.6 | 6.75 | 23 | 41.72 | 23 | 13 | 0.8 | 26 | 15 | 0 | 19 | 4 | 0.46 | 0.3 | 27 | 0.6 | 0.6 | 90 | 76 | 834 |
| 257061 | LT-4B | 0-20 | 5.9 | 6.82 | 16 | 43.53 | 35 | 20 | 0.9 | 35 | 21 | 0 | 18 | 3 | 0.37 | 0.2 | 26 | 1.6 | 0.6 | 116 | 90 | 794 |
| 257062 | LT-5A | 0-20 | 5.3 | 6.44 | 33 | 35.90 | 21 | 12 | 1.3 | 18 | 10 | 0 | 27 | 4 | 0.29 | 0.2 | 27 | 1.2 | 0.6 | 93 | 77 | 830 |
| 257063 | LT-5B | 0-20 | 5.5 | 6.49 | 33 | 38.89 | 24 | 14 | 1.1 | 26 | 12 | 0 | 25 | 2 | 0.42 | 0.3 | 19 | 1.0 | 1.0 | 127 | 72 | 801 |
| 257064 | LT-5B | 20-40 | 5.1 | 6.33 | 12 | 35.90 | 19 | 11 | 0.8 | 16 | 7 | 0 | 30 | 3 | 0.28 | 0.2 | 27 | 1.2 | 0.5 | 117 | 83 | 800 |
| 257065 | LT-6A | 0-20 | 5.0 | 6.13 | 21 | 32.02 | 26 | 15 | 1.0 | 20 | 8 | 0 | 37 | 3 | 0.50 | 0.2 | 20 | 0.8 | 0.7 | 182 | 55 | 763 |
| 257066 | LT-6B | 0-20 | 5.4 | 6.53 | 12 | 37.18 | 24 | 14 | 0.5 | 19 | 6 | 0 | 24 | 4 | 0.32 | 0.1 | 18 | 0.6 | 0.6 | 103 | 100 | 797 |
| 257067 | 6 Bico | 0-20 | 4.7 | 5.23 | 11 | 7.30 | 67 | 39 | 1.2 | 25 | 8 | 3 | 95 | 3 | 1.24 | 0.3 | 19 | 0.4 | 0.4 | 267 | 94 | 639 |
| 257068 | 07 | 0-20 | 5.6 | 6.72 | 13 | 37.31 | 29 | 17 | 1.3 | 25 | 11 | 0 | 20 | 4 | 0.41 | 0.2 | 20 | 0.6 | 0.4 | 141 | 21 | 838 |
| 257069 | 08 | 0-20 | 5.3 | 6.11 | 17 | 29.85 | 49 | 28 | 2.6 | 58 | 32 | 0 | 38 | 4 | 0.95 | 0.3 | 37 | 9.0 | 0.8 | 168 | 123 | 709 |

---

## Laboratório 3 — MB Agronegócios

**Identificação no PDF:** "MB AGRONEGOCIOS" ou "grupomb.agr.br" ou "MB AGRONEG"
**Arquivo de referência:** Análise 78416, Fazenda Flamboyat

### Particularidades do formato MB

- Layout em **blocos temáticos** (Parâmetros Estratégicos + Teores Químicos)
- Unidades de Ca, Mg, K, H+Al, Al em **cmol/dm³** (igual cmolc/dm³) — sem conversão
- `P-meh` = pMehlich
- `P-REMANESCENTE` = pRem (campo separado no rodapé)
- `P-RESINA` = pResina (campo separado no rodapé)
- `K` em mg/dm³ na tabela principal — converter ÷ 391 para cmolc/dm³
- `S` = enxofre, mas aparece como `nr` (não requisitado) — tratar como null
- Micronutrientes: Fe, Mn, Zn, Cu também aparecem como `nr` neste laudo — null
- `M.O.` em % (= dag/kg) — sem conversão necessária
- `Carbono` em g/dm³ → carbonoOrganico

### Mapeamento MB → canônico

```dart
const mbFieldMap = {
  'pH CaCl2':          'phCaCl2',
  'pH SMP':            'phSmp',
  'Matéria orgânica':  'materiaOrganica',   // já em %
  'Carbono':           'carbonoOrganico',   // g/dm³ ÷ 10
  'P-meh':             'pMehlich',
  'P-REMANESCENTE':    'pRem',
  'P-RESINA':          'pResina',
  'H+Al':              'hMaisAl',
  'Al':                'al',
  'Ca':                'ca',
  'Mg':                'mg',
  'K':                 'k_mgdm3',           // converter ÷ 391
  'S':                 's020',
  'Argila':            'argila',
  'Silte':             'silte',
  'Areia Total':       'areiaTotal',
};
```

### Arquivos a criar

```
lib/data/lab_templates/
  mb_template.dart
  mb_import_service.dart

assets/lab_data/
  mb_78416_2025.json    ← 1 amostra TH ABACAXI
```

### JSON mb_78416_2025.json

```json
{
  "fonte": "MB Agronegócios",
  "analise": "78416",
  "dataEntrada": "2025-07-25",
  "dataSaida": "2025-08-07",
  "cliente": "Timac Agro Industria E Com. De Fert.",
  "fazenda": "Edmilson Hayasaki - Flamboyat",
  "cidade": "Figueiropolis - TO",
  "responsavel": "Larissa Urzedo Rodrigues",
  "laboratorio": "MB Agronegócios",
  "amostras": [
    {
      "numeroAmostra": "78416",
      "talhao": "TH ABACAXI",
      "profundidade": "0-20",
      "phCaCl2": 5.80,
      "phSmp": 6.76,
      "materiaOrganica": 1.94,
      "carbonoOrganico": 1.125,
      "pMehlich": 6.53,
      "pResina": null,
      "pRem": null,
      "s020": null,
      "k_mgdm3": 31.74,
      "ca": 2.95,
      "mg": 1.02,
      "al": 0.00,
      "hMaisAl": 1.90,
      "na": null,
      "b": null,
      "cu": null,
      "fe": null,
      "mn": null,
      "zn": null,
      "ni": null,
      "mo": null,
      "se": null,
      "argila": 42.00,
      "silte": 4.36,
      "areiaTotal": 53.64
    }
  ]
}
```

> ⚠️ Atenção: MB usa % para argila/silte/areia (não g/kg). Registrar no template e converter × 10 ao importar para manter g/kg canônico.

---

## Atualizar LabDetector

Após criar os 3 templates, atualizar `lib/data/lab_templates/lab_detector.dart`:

```dart
class LabDetector {
  static String? detectar(String textoPdf) {
    final t = textoPdf.toLowerCase();
    if (t.contains('sellar'))                          return 'sellar';
    if (t.contains('exata brasil') || t.contains('exatabrasil.com.br')) return 'exata_brasil';
    if (t.contains('instituto brasileiro de análises') || t.contains('ibra.com.br')) return 'ibra';
    if (t.contains('mb agronegocios') || t.contains('grupomb.agr.br')) return 'mb';
    return null;
  }
}
```

---

## Ordem de execução

```
Passo 1  → Ler sellar_template.dart e sellar_import_service.dart (referência)
Passo 2  → Criar exata_brasil_template.dart
Passo 3  → Criar exata_brasil_import_service.dart
Passo 4  → Criar assets/lab_data/exata_brasil_16723_2024.json (12 amostras)
Passo 5  → Criar assets/lab_data/exata_brasil_17259_2025.json (28 amostras)
Passo 6  → flutter analyze
Passo 7  → Criar ibra_template.dart
Passo 8  → Criar ibra_import_service.dart
Passo 9  → Criar assets/lab_data/ibra_237526_2025.json (14 amostras)
Passo 10 → flutter analyze
Passo 11 → Criar mb_template.dart
Passo 12 → Criar mb_import_service.dart
Passo 13 → Criar assets/lab_data/mb_78416_2025.json (1 amostra)
Passo 14 → Atualizar lab_detector.dart com os 4 laboratórios
Passo 15 → Declarar novos assets em pubspec.yaml (se ainda não cobertos por assets/lab_data/)
Passo 16 → flutter analyze final — zero erros
Passo 17 → flutter test — todos passando
```

---

## Testes mínimos a adicionar

Em `test/data/` criar ou atualizar arquivo de testes:

```
exata_brasil_import_service_test.dart
  → 12 amostras do 16723
  → amostra[0].phCaCl2 == 5.05
  → amostra[0].k != null && amostra[0].k < 1.0  (conversão mg/dm³ → cmolc)
  → amostra[0].materiaOrganica < 10.0             (conversão g/dm³ → dag/kg)

ibra_import_service_test.dart
  → 14 amostras
  → amostra[0].phCaCl2 == 5.8
  → amostra[0].ca < 5.0  (conversão mmolc → cmolc)
  → amostra[6].talhao == 'LT-5B'  (amostra 257062, profundidade 0-20)

mb_import_service_test.dart
  → 1 amostra
  → amostra[0].phCaCl2 == 5.80
  → amostra[0].pMehlich == 6.53
  → amostra[0].argila == 420.0  (42% × 10 = 420 g/kg)
```

---

## Mensagem final

> "Templates criados: Exata Brasil (2 relatórios, 40 amostras), IBRA (14 amostras), MB (1 amostra). LabDetector atualizado com 4 laboratórios. flutter analyze: 0 erros. flutter test: todos passando."
