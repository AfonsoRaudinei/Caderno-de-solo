# Instrução para Agente — Template de Mapeamento Sellar → SoloForte

> **Objetivo:** criar um arquivo de mapeamento fixo que traduz os campos do laudo PDF da Sellar Análises Agrícolas para os campos canônicos do SoloForte.  
> **Não implementar parser de PDF agora.** Apenas criar a estrutura de mapeamento e o serviço de carga a partir de JSON.  
> **Regra:** pare e pergunte se qualquer arquivo referenciado não existir.

---

## 0. Antes de começar

1. Leia `lib/features/analise/domain/entities/analise_solo.dart` — confirme os nomes canônicos dos campos (definidos na instrução anterior).
2. Leia `lib/data/models/analise_model.dart` — confirme estrutura de serialização.
3. Se qualquer campo canônico listado abaixo não existir na entidade → pare e informe.

---

## 1. Arquivo a criar: `SellarTemplate`

**Caminho:** `lib/data/lab_templates/sellar_template.dart`

Este arquivo é a fonte da verdade do mapeamento Sellar. Contém:

### 1.1 Identificação do laboratório

```dart
const sellarLabInfo = LabInfo(
  id: 'sellar',
  nome: 'Sellar Análises Agrícolas',
  cnpj: '17.985.831/0001-62',
  extratores: {
    'pk':      'Mehlich 1',
    'cuFeMnZn':'DTPA',
    'caMgAl':  'KCl 1M',
    's':       'Fosfato monobásico de Cálcio',
    'b':       'Água quente',
    'pResina': 'Resina',
  },
);
```

### 1.2 Mapeamento de campos — JSON Sellar → campo canônico

Crie um `Map<String, String>` chamado `sellarFieldMap` onde:
- chave = nome do campo como aparece no JSON do laudo Sellar
- valor = nome canônico do campo em `AnaliseSolo`

```dart
const sellarFieldMap = {
  // Identificação
  'identificacao':   'talhao',
  'numeroSellar':    'numeroAmostra',
  'profundidade':    'profundidade',

  // pH
  'phCaCl2':         'phCaCl2',
  'phAgua':          'phAgua',
  'phSmp':           'phSmp',

  // Matéria Orgânica
  'materiaOrganica': 'materiaOrganica',
  'carbonoOrganico': 'carbonoOrganico',

  // Fósforo
  'pMehlich':        'pMehlich',
  'pResina':         'pResina',
  'pRem':            'pRem',

  // Enxofre
  's020':            's020',
  's2040':           's2040',

  // Macronutrientes
  'k':               'k',
  'ca':              'ca',
  'mg':              'mg',
  'al':              'al',
  'hMaisAl':         'hMaisAl',
  'na':              'na',

  // Micronutrientes
  'b':               'b',
  'cu':              'cu',
  'fe':              'fe',
  'mn':              'mn',
  'zn':              'zn',
  'ni':              'ni',
  'mo':              'mo',
  'se':              'se',

  // Composição Física
  'argila':          'argila',
  'silte':           'silte',
  'areiaTotal':      'areiaTotal',
};
```

**Campos ignorados do JSON Sellar** (presentes no JSON mas não vão para `AnaliseSolo`):
- `derivados` — são recalculados pelo app, nunca importados
- `extratores` — vai para `LabInfo`, não para a amostra
- `laudoNumero`, `dataEntrada`, `dataGeracao` — metadados do laudo, gravar em campo separado `laudoMetadata`

---

## 2. Arquivo a criar: `LabInfo`

**Caminho:** `lib/domain/entities/lab_info.dart`

```dart
class LabInfo {
  final String id;
  final String nome;
  final String? cnpj;
  final Map<String, String> extratores;

  const LabInfo({
    required this.id,
    required this.nome,
    this.cnpj,
    required this.extratores,
  });
}
```

---

## 3. Arquivo a criar: `SellarImportService`

**Caminho:** `lib/data/lab_templates/sellar_import_service.dart`

Este serviço recebe o JSON do laudo Sellar e retorna uma lista de `AnaliseSolo` prontos para exibir na tabela e salvar.

```dart
class SellarImportService {

  /// Recebe o Map decodificado do JSON Sellar.
  /// Retorna lista de AnaliseSolo — uma por amostra.
  List<AnaliseSolo> fromJson(Map<String, dynamic> json) {
    final amostras = json['amostras'] as List;
    return amostras.map((a) => _mapAmostra(a as Map<String, dynamic>, json)).toList();
  }

  AnaliseSolo _mapAmostra(Map<String, dynamic> amostra, Map<String, dynamic> laudo) {
    // 1. Para cada entrada em sellarFieldMap:
    //    - busca a chave no mapa `amostra`
    //    - atribui ao campo canônico correspondente em AnaliseSolo
    // 2. Campos do cabeçalho do laudo (solicitante, propriedade, municipio)
    //    são mapeados para os campos de identificação da análise
    // 3. Campos `derivados` são IGNORADOS — o app recalcula
    // 4. Campos null no JSON → null na entidade (não zero)
  }
}
```

**Regras do serviço:**
- Nunca lançar exceção silenciosa — se um campo esperado estiver ausente no JSON, logar o campo ausente e continuar com `null`.
- Nunca importar os `derivados` do JSON — sempre recalcular via `calcularDerivados()` da instrução anterior.
- Campos `null` no JSON devem chegar como `null` na entidade, não como `0` ou `''`.

---

## 4. Arquivo de dados: JSON do primeiro laudo real

**Caminho:** `assets/lab_data/sellar_6077_2025.json`

Cole o conteúdo do arquivo `sellar_6077_2025.json` que foi fornecido.  
Este é o primeiro laudo real de treinamento/teste do template Sellar.

Adicione o asset em `pubspec.yaml` se a pasta `assets/lab_data/` ainda não estiver declarada:

```yaml
flutter:
  assets:
    - assets/lab_data/
```

---

## 5. Teste mínimo

**Caminho:** `test/data/sellar_import_service_test.dart`

Escreva um teste que:
1. Carrega o JSON `sellar_6077_2025.json`
2. Chama `SellarImportService().fromJson(json)`
3. Verifica que retorna 3 amostras
4. Verifica que amostra[0].phCaCl2 == 5.4
5. Verifica que amostra[0].pMehlich == 13.8
6. Verifica que amostra[0].derivados NÃO são importados (campo `sb` não vem do JSON)
7. Verifica que campos `null` no JSON chegam como `null` (ex: `phAgua`)

---

## 6. Estrutura de pastas resultante

```
lib/
  domain/
    entities/
      lab_info.dart                        ← CRIAR
  data/
    lab_templates/
      sellar_template.dart                 ← CRIAR
      sellar_import_service.dart           ← CRIAR
assets/
  lab_data/
    sellar_6077_2025.json                  ← ADICIONAR
test/
  data/
    sellar_import_service_test.dart        ← CRIAR
```

---

## 7. Regras de parada obrigatória

| Situação | O que fazer |
|---|---|
| Campo canônico não existe na entidade `AnaliseSolo` | Pare. Liste os campos ausentes. |
| `pubspec.yaml` já declara `assets/` com estrutura diferente | Pare. Mostre a estrutura atual. |
| Qualquer import quebrado após criar os arquivos | Pare. Liste os erros antes de avançar. |
| `flutter analyze` com erros | Pare. Não avance para o próximo arquivo. |

---

## 8. Ordem de execução

```
Passo 1 → Criar lab_info.dart
Passo 2 → Criar sellar_template.dart  
Passo 3 → Criar sellar_import_service.dart
Passo 4 → Adicionar JSON em assets/lab_data/ e declarar em pubspec.yaml
Passo 5 → Criar sellar_import_service_test.dart
Passo 6 → flutter test test/data/sellar_import_service_test.dart
Passo 7 → flutter analyze — zero erros
```

---

## 9. O que NÃO fazer nesta instrução

- ❌ Não implementar leitura de PDF ainda
- ❌ Não conectar ao botão "Importar Laudo PDF" da tela ainda
- ❌ Não criar UI de seleção de laboratório ainda
- ❌ Não importar os valores de `derivados` do JSON

Essas etapas vêm depois, quando o template estiver validado com dados reais.

---

## 10. Mensagem final ao terminar

> "Template Sellar criado. 3 amostras importadas do laudo 6077/2025. Todos os testes passando. Pronto para conectar ao botão de importação da tela."
