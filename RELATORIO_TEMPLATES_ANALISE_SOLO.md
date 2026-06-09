# Relatório — Templates de Análise de Solo (Lab Templates)

Gerado em: 2026-05-29

Este relatório lista **todos os templates de análise de solo criados** no projeto, incluindo:
- Templates “padrão” (entidade `LabTemplate`) carregados no app.
- Templates de importação/parsing (mapas de campos e regras por laboratório).
- Templates em `assets/` (regex/mapeamentos e dados de validação).

---

## 1) Templates padrão carregados no app

Fonte: `Analise/lib/core/constants/default_lab_templates.dart`

> Estes templates são instâncias de `LabTemplate` usadas como configuração padrão (unidades, flags de campos entregues e sinais/keywords).

| id | nome | createdAt | Observações rápidas |
| --- | --- | --- | --- |
| `ibra_default` | IBRA | 2025-01-01 | Micros via **DTPA**, K/Ca/Mg/Al/H+Al em **mmolc/dm³**, textura em **g/kg** |
| `exata_default` | Exata Brasil | 2025-01-01 | Micros via **Mehlich** e **DTPA**, pH água + SMP, K pode vir como **NH4Cl** |
| `mb_default` | MB Agronegócios | 2025-01-01 | 1 amostra por laudo, pode ter areias detalhadas/cascalho, MO em **%** |
| `sellar_default` | Sellar | 2025-01-01 | Campos extras (CTCe, pH água, P total, classificação de textura, tipo de solo mapa) |
| `solum_default` | Solum | 2025-01-01 | Identificação composta, micros por amostra, pH **SMP** (sem pH água), textura geralmente ausente |

---

## 2) Templates de importação/parsing por laboratório

Fonte: `Analise/lib/data/lab_templates/`

### 2.1) Labs suportados pelo detector (PDF)

Fonte: `Analise/lib/data/lab_templates/lab_detector.dart`

Conjunto `supportedLabs`:
- `sellar`
- `solum`
- `exata_brasil`
- `ibra`
- `mb`

### 2.2) Mapas de campos (JSON → canônico interno)

Arquivos:
- `Analise/lib/data/lab_templates/ibra_template.dart`
  - `ibraLabInfo`, `ibraFieldMap`, `ibraIgnoredFields`
- `Analise/lib/data/lab_templates/exata_brasil_template.dart`
  - `exataBrasilLabInfo`, `exataBrasilFieldMap`, `exataBrasilIgnoredFields`
- `Analise/lib/data/lab_templates/mb_template.dart`
  - `mbLabInfo`, `mbFieldMap`, `mbIgnoredFields`
- `Analise/lib/data/lab_templates/sellar_template.dart`
  - `sellarLabInfo`, `sellarFieldMap`, `sellarIgnoredFields`
- `Analise/lib/data/lab_templates/solum_template.dart`
  - `solumLabInfo` (**apenas metadados; sem `FieldMap` neste arquivo**)

### 2.3) Pipeline de importação de PDF

Arquivos principais (orquestração e serviços):
- `Analise/lib/data/lab_templates/pdf_import_service.dart`
- `Analise/lib/data/lab_templates/lab_pdf_parser.dart`
- `Analise/lib/data/lab_templates/pdf_text_extractor.dart`
- `Analise/lib/data/lab_templates/*_import_service.dart` (um por laboratório)

---

## 3) Templates em assets (regex / mapeamentos)

### 3.1) Template regex “Soloagro”

Arquivo:
- `Analise/assets/lab_templates/soloagro.json`

Observação:
- Carregado por `PdfParserDatasource.loadLabTemplates()` em `Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart`.

---

## 4) Dados de validação (ground truth) de importação

Fonte: `Analise/assets/lab_data/`

Arquivos encontrados:
- `exata_brasil_16723_2024.json`
- `exata_brasil_16738_2025.json`
- `exata_brasil_17259_2025.json`
- `exata_brasil_20573_2024.json`
- `ibra_235421_2025.json`
- `ibra_237526_2025.json`
- `mb_78416_2025.json`
- `mb_78418_2025.json`
- `sellar_6077_2025.json`

