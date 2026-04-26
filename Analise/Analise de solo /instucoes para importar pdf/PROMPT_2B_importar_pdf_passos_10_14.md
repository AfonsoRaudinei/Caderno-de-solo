# Prompt — Continuação PROMPT_2: Passos 10–14 (Botão Importar PDF)

> Este prompt continua de onde o PROMPT_2 parou.
> Passos 1–9 (tabela planilha + NovaAnaliseController) já foram concluídos.
> Regra: pare apenas se flutter analyze retornar erros ou arquivo referenciado não existir.

---

## Contexto atual

Já existem:
- `AnaliseTableWidget` e widgets de célula ✅
- `NovaAnaliseController` com `carregarDeImportacao()` ✅
- `NovaAnaliseScreen` com tabela planilha ✅
- `SellarImportService` ✅
- `ExataBrasilImportService` ✅
- `IbraImportService` ✅
- `MbImportService` ✅
- `LabDetector` com 4 laboratórios ✅
- `lab_info.dart` ✅

---

## Passo 10 — Verificar packages de PDF disponíveis

Leia `pubspec.yaml` e liste todos os packages relacionados a PDF presentes.

Possibilidades esperadas:
- `syncfusion_flutter_pdf`
- `pdfx`
- `pdf` (dart-pdf)
- `flutter_pdfview`
- `printing`

**Se nenhum package de extração de texto estiver presente:**
- Não adicione nenhum package
- Implemente o fluxo de fallback descrito abaixo
- Reporte: "Nenhum package de PDF encontrado. Implementando fluxo de fallback."

**Se algum package estiver presente:**
- Use o que já existe
- Reporte qual package encontrou antes de implementar

---

## Passo 11 — Criar `PdfImportService`

**Caminho:** `lib/data/lab_templates/pdf_import_service.dart`

Este serviço orquestra todo o fluxo de importação:

```dart
class PdfImportService {

  /// Abre o FilePicker, detecta o laboratório e retorna
  /// lista de AnaliseSolo prontos para carregar na tabela.
  ///
  /// Retorna null se o usuário cancelar.
  /// Lança [LabNaoReconhecidoException] se o PDF não for reconhecido.
  /// Lança [ExtracacaoIndisponivelException] se não houver package de PDF.
  Future<List<AnaliseSolo>?> importarDePdf(BuildContext context) async {
    // 1. Abrir FilePicker — tipo PDF
    // 2. Se cancelou → retornar null
    // 3. Tentar extrair texto do PDF
    //    → Se package disponível: extrair texto
    //    → Se não disponível: lançar ExtracacaoIndisponivelException
    // 4. LabDetector.detectar(texto)
    //    → Se null: lançar LabNaoReconhecidoException
    // 5. Instanciar o ImportService correto
    // 6. Converter texto → Map<String, dynamic> (parsing básico)
    // 7. Chamar fromJson() do ImportService
    // 8. Retornar lista de AnaliseSolo
  }
}

class LabNaoReconhecidoException implements Exception {
  final String message = 'Laboratório não reconhecido';
}

class ExtracacaoIndisponivelException implements Exception {
  final String message = 'Extração de texto de PDF não disponível neste momento';
}
```

---

## Passo 12 — Criar `ImportacaoBottomSheet`

**Caminho:** `lib/features/analise/presentation/widgets/importacao_bottom_sheet.dart`

Dois estados visuais — ambos no mesmo widget, controlados por parâmetro `tipo`:

### Estado A — Laboratório não reconhecido

```
┌─────────────────────────────────┐
│  ────  (drag handle)            │
│                                 │
│  Laboratório não reconhecido    │  ← título, fontSize 16, peso 500
│                                 │
│  Este PDF não corresponde a     │  ← texto, fontSize 14, cor secondary
│  nenhum laboratório cadastrado. │
│  Insira os dados manualmente.   │
│                                 │
│  [  Digitar manualmente  ]      │  ← botão primário azul, altura 50
│  [       Cancelar        ]      │  ← botão secundário cinza, altura 44
└─────────────────────────────────┘
```

### Estado B — Extração não disponível

```
┌─────────────────────────────────┐
│  ────  (drag handle)            │
│                                 │
│  Importação automática          │  ← título
│  indisponível                   │
│                                 │
│  A leitura automática de PDF    │  ← texto secondary
│  não está disponível no momento.│
│  Insira os dados manualmente    │
│  ou tente novamente mais tarde. │
│                                 │
│  [  Digitar manualmente  ]      │
│  [       Cancelar        ]      │
└─────────────────────────────────┘
```

**Tokens visuais:**
- Background: `AppColors.bgPrimary`
- Border radius top: 16px
- Padding: 24px horizontal, 20px vertical
- Drag handle: 4×40px, cor `AppColors.border`, radius 2px
- Botão primário: `AppColors.primary`, radius 12px, altura 50px
- Botão secundário: `AppColors.bgSecondary`, radius 12px, altura 44px
- Nenhuma cor de status, nenhum ícone decorativo

---

## Passo 13 — Conectar botão na `NovaAnaliseScreen`

Localize o botão "Importar Laudo PDF" existente na `NovaAnaliseScreen`.

Substitua sua ação atual por:

```dart
onTap: () async {
  try {
    final analises = await PdfImportService().importarDePdf(context);
    if (analises == null) return; // usuário cancelou

    controller.carregarDeImportacao(
      analises.map((a) => a.toMap()).toList(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${analises.length} amostras importadas — revise e salve'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  } on LabNaoReconhecidoException {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.labNaoReconhecido,
          onDigitarManualmente: () => Navigator.pop(context),
        ),
      );
    }
  } on ExtracacaoIndisponivelException {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.extracacaoIndisponivel,
          onDigitarManualmente: () => Navigator.pop(context),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }
},
```

---

## Passo 14 — flutter analyze + flutter test

```
flutter analyze       → zero erros obrigatório
flutter test          → todos passando obrigatório
```

Se algum teste quebrar por causa da nova estrutura do controller → ajustar o teste para refletir o novo comportamento, não reverter o código.

---

## Estrutura final de arquivos criados neste prompt

```
lib/
  data/
    lab_templates/
      pdf_import_service.dart          ← CRIAR
  features/
    analise/
      presentation/
        widgets/
          importacao_bottom_sheet.dart ← CRIAR
```

---

## Mensagem final

> "Botão Importar PDF conectado. PdfImportService criado. BottomSheet de erro implementado. flutter analyze: 0 erros. flutter test: todos passando."
