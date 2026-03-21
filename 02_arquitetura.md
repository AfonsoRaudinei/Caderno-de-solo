# 🏗️ Arquitetura — Clean Architecture Flutter

> Baseado no manual de boas práticas Flutter/Dart.  
> Separação clara entre **dados**, **regras de negócio** e **interface**.

---

## 📁 Estrutura de Pastas

```
lib/
│
├── core/                          # Compartilhado por todo o app
│   ├── theme/
│   │   ├── app_colors.dart        # Paleta iOS (#007AFF, #F5F5F7...)
│   │   ├── app_text_styles.dart   # Hierarquia tipográfica
│   │   └── app_theme.dart         # ThemeData principal
│   ├── constants/
│   │   ├── app_strings.dart       # Textos e labels
│   │   └── app_routes.dart        # Nomes das rotas go_router
│   ├── utils/
│   │   ├── formatters.dart        # Formatação de números, datas
│   │   └── validators.dart        # Validações de formulários
│   └── widgets/                   # Widgets reutilizáveis globais
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_input.dart
│       └── app_dropdown.dart
│
├── data/                          # Fontes de dados
│   ├── models/                    # DTOs com json_serializable
│   │   ├── analise_model.dart
│   │   ├── calibracao_model.dart
│   │   ├── recomendacao_model.dart
│   │   └── usuario_model.dart
│   ├── datasources/
│   │   ├── local/                 # Hive / ObjectBox
│   │   │   └── calibracao_local_datasource.dart
│   │   └── remote/                # dio + API
│   │       ├── analise_remote_datasource.dart
│   │       └── auth_remote_datasource.dart
│   └── repositories/              # Implementações dos contratos
│       ├── analise_repository_impl.dart
│       └── calibracao_repository_impl.dart
│
├── domain/                        # Regras de negócio puras
│   ├── entities/                  # Modelos imutáveis (freezed)
│   │   ├── analise.dart
│   │   ├── calibracao.dart
│   │   ├── recomendacao.dart
│   │   └── usuario.dart
│   ├── repositories/              # Contratos (interfaces)
│   │   ├── analise_repository.dart
│   │   └── calibracao_repository.dart
│   ├── usecases/                  # Casos de uso
│   │   ├── calcular_recomendacao_usecase.dart
│   │   ├── salvar_analise_usecase.dart
│   │   └── buscar_historico_usecase.dart
│   └── formulas/                  # Fórmulas técnicas de solo
│       ├── calcario_formula.dart
│       ├── gesso_formula.dart
│       ├── potassio_formula.dart
│       ├── fosforo_formula.dart
│       ├── enxofre_formula.dart
│       └── micronutrientes_formula.dart
│
└── presentation/                  # Interface do usuário
    ├── auth/
    │   ├── login/
    │   │   ├── login_page.dart
    │   │   └── login_controller.dart
    │   ├── cadastro/
    │   │   ├── cadastro_page.dart
    │   │   └── cadastro_controller.dart
    │   └── recuperar_senha/
    │       └── recuperar_senha_page.dart
    │
    ├── analise/
    │   ├── analise_page.dart
    │   └── analise_controller.dart
    │
    ├── lab/                       # Tab "Lab" — Calibração + Recomendação
    │   ├── lab_page.dart          # TabBar container
    │   ├── calibracao/
    │   │   ├── calibracao_page.dart
    │   │   ├── calibracao_controller.dart
    │   │   └── widgets/
    │   │       ├── nutriente_card.dart
    │   │       └── referencia_item.dart
    │   └── recomendacao/
    │       ├── recomendacao_page.dart
    │       ├── recomendacao_controller.dart
    │       └── widgets/
    │           ├── recomendacao_card.dart
    │           └── referencia_citacao.dart   # Estilo Perplexity
    │
    ├── historico/
    │   ├── historico_page.dart
    │   └── historico_controller.dart
    │
    └── config/
        ├── config_page.dart
        ├── base_dados/
        │   ├── base_dados_page.dart
        │   └── base_dados_controller.dart
        ├── perfil/
        │   └── perfil_page.dart
        └── feedback/
            └── feedback_page.dart
```

---

## 🔄 Fluxo de Dados

```
Widget (UI)
    ↓ dispara evento
Controller / Notifier (Riverpod)
    ↓ chama
Use Case (domain)
    ↓ usa
Repository (contrato domain / impl data)
    ↓ acessa
DataSource (local Hive ou remote dio)
    ↓ retorna
Entity → State → Widget re-renderiza
```

---

## 📐 Regras de Camada

| Camada | Pode depender de | NÃO pode depender de |
|---|---|---|
| `core` | nada externo | — |
| `domain` | `core` | `data`, `presentation`, Flutter SDK |
| `data` | `domain`, `core` | `presentation` |
| `presentation` | `domain`, `core` | `data` diretamente |

---

## ⚗️ Fórmulas — Domínio Central

As fórmulas de solo ficam em `domain/formulas/` isoladas e testáveis:

```dart
// Exemplo: calcario_formula.dart
abstract class CalcarioFormula {
  static double calcularNecessidade({
    required double phAtual,
    required double phDesejado,
    required double argila,
    required double ctc,
    required String metodo, // IAC, Embrapa, etc
  }) {
    // lógica da fórmula
  }
}
```

Cada nutriente tem sua própria classe de fórmula com a referência técnica documentada.

---

## 🔗 Calibração → Recomendação (Riverpod)

```dart
// calibracao_provider.dart
final calibracaoProvider = StateNotifierProvider<CalibracaoNotifier, CalibracaoState>(...);

// recomendacao_provider.dart — observa calibração automaticamente
final recomendacaoProvider = Provider((ref) {
  final calibracao = ref.watch(calibracaoProvider);
  final analise = ref.watch(analiseProvider);
  return calcularRecomendacao(calibracao, analise);
});
```

---

*Versão 1.0*
