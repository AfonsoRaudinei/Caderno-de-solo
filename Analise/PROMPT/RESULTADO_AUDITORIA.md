# RESULTADO AUDITORIA — SoloForte
Data: 2026-04-25 09:42:54 -03
Flutter: Flutter 3.41.6 • channel stable • https://github.com/flutter/flutter.git
Dart: Dart SDK version: 3.11.4 (stable) (Tue Mar 24 01:02:20 2026 -0700) on "macos_arm64"

---

## ÍNDICE DE STATUS

| Bloco | Área | Status | Críticos |
|-------|------|--------|----------|
| 1 | Saúde do Projeto | ✅ | 0 |
| 2 | Arquitetura | ⚠️ | 0 |
| 3 | Estado (Riverpod) | 🚨 | 2 |
| 4 | Fórmulas Agronômicas | 🚨 | 1 |
| 5 | Parsers de PDF | ⚠️ | 0 |
| 6 | Firebase e Dados | ⚠️ | 0 |
| 7 | Navegação | ⚠️ | 0 |
| 8 | UI e Design System | ⚠️ | 0 |
| 9 | Build e CI/CD | ⚠️ | 0 |
| 10 | Testes | ✅ | 0 |
| 11 | Segurança e Qualidade | ⚠️ | 0 |
| 12 | Pendências Conhecidas | ⚠️ | 0 |

---

## MAPA DE ARQUIVOS DART

```
lib/core/config/app_config.dart
lib/core/constants/app_routes.dart
lib/core/constants/app_strings.dart
lib/core/router/app_router.dart
lib/core/services/app_observability.dart
lib/core/services/location_service.dart
lib/core/theme/app_colors.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_theme.dart
lib/core/utils/location_service.dart
lib/core/utils/safra_utils.dart
lib/core/widgets/app_button.dart
lib/core/widgets/app_card.dart
lib/core/widgets/app_dropdown.dart
lib/core/widgets/app_input.dart
lib/core/widgets/formatters/digit_limit_formatter.dart
lib/core/widgets/nutriente_card.dart
lib/data/base_dados/nc_por_referencia.dart
lib/data/base_dados/referencias_tecnicas_data.dart
lib/data/culturas_data.dart
lib/data/datasources/local/calibracao_hive_datasource.dart
lib/data/datasources/local/calibracao_mock_db.dart
lib/data/datasources/remote/analise_firestore_datasource.dart
lib/data/datasources/remote/auth_datasource.dart
lib/data/datasources/remote/calibracao_firestore_datasource.dart
lib/data/datasources/remote/recomendacao_firestore_datasource.dart
lib/data/lab_templates/exata_brasil_import_service.dart
lib/data/lab_templates/exata_brasil_template.dart
lib/data/lab_templates/ibra_import_service.dart
lib/data/lab_templates/ibra_template.dart
lib/data/lab_templates/lab_detector.dart
lib/data/lab_templates/lab_pdf_parser.dart
lib/data/lab_templates/mb_import_service.dart
lib/data/lab_templates/mb_template.dart
lib/data/lab_templates/pdf_import_service.dart
lib/data/lab_templates/pdf_text_extractor.dart
lib/data/lab_templates/sellar_import_service.dart
lib/data/lab_templates/sellar_template.dart
lib/data/repositories/auth_repository_impl.dart
lib/domain/entities/analise_entity.dart
lib/domain/entities/analise_entity.freezed.dart
lib/domain/entities/analise_entity.g.dart
lib/domain/entities/calibracao_entity.dart
lib/domain/entities/citacao_calibracao_model.dart
lib/domain/entities/lab_info.dart
lib/domain/entities/resultado_calagem.dart
lib/domain/entities/resultado_calagem.freezed.dart
lib/domain/entities/resultado_calagem.g.dart
lib/domain/entities/resultado_gesso.dart
lib/domain/formulas/calagem_engine.dart
lib/domain/formulas/calcario_formula.dart
lib/domain/formulas/conversoes.dart
lib/domain/formulas/fosforo_formula.dart
lib/domain/formulas/gesso_engine.dart
lib/domain/formulas/micronutrientes_engine.dart
lib/domain/formulas/potassio_formula.dart
lib/domain/formulas/types/calcario_input.dart
lib/domain/formulas/types/calcario_input.freezed.dart
lib/domain/formulas/types/fosforo_input.dart
lib/domain/formulas/types/fosforo_input.freezed.dart
lib/domain/formulas/types/gesso_input.dart
lib/domain/formulas/types/gesso_input.freezed.dart
lib/domain/models/analise_model.dart
lib/domain/models/analise_model.freezed.dart
lib/domain/models/analise_model.g.dart
lib/domain/models/calibracao_profile.dart
lib/domain/models/location_data_model.dart
lib/domain/models/location_data_model.freezed.dart
lib/domain/models/location_data_model.g.dart
lib/domain/models/recomendacao_model.dart
lib/domain/models/recomendacao_model.freezed.dart
lib/domain/models/recomendacao_model.g.dart
lib/domain/repositories/auth_repository.dart
lib/domain/services/location_service.dart
lib/domain/usecases/calcular_recomendacao_usecase.dart
lib/domain/usecases/recomendacao_engine.dart
lib/domain/usecases/recomendacao_engine.freezed.dart
lib/features/analise/application/observability/analise_telemetry.dart
lib/features/analise/application/providers/analise_provider.dart
lib/features/analise/application/providers/analise_telemetry_provider.dart
lib/features/analise/data/datasources/analise_datasource.dart
lib/features/analise/data/datasources/analise_local_datasource.dart
lib/features/analise/data/datasources/pdf_parser_datasource.dart
lib/features/analise/data/models/analise_solo_model.dart
lib/features/analise/data/models/lab_template_model.dart
lib/features/analise/data/models/produtor_model.dart
lib/features/analise/data/repositories/analise_repository_impl.dart
lib/features/analise/domain/entities/analise_solo.dart
lib/features/analise/domain/entities/produtor.dart
lib/features/analise/domain/formulas/fosforo_provider.dart
lib/features/analise/domain/models/analise_draft.dart
lib/features/analise/domain/persistence/save_batch.dart
lib/features/analise/domain/repositories/analise_repository.dart
lib/features/analise/domain/usecases/calcular_derivados_analise.dart
lib/features/analise/domain/usecases/delete_analise_usecase.dart
lib/features/analise/domain/usecases/get_analises_usecase.dart
lib/features/analise/domain/usecases/parse_pdf_usecase.dart
lib/features/analise/domain/usecases/save_analise_usecase.dart
lib/features/analise/domain/validation/analise_data_contract.dart
lib/features/analise/presentation/controllers/analise_controller.dart
lib/features/analise/presentation/controllers/analise_controller.g.dart
lib/features/analise/presentation/controllers/nova_analise_controller.dart
lib/features/analise/presentation/formatters/analise_number_formatter.dart
lib/features/analise/presentation/models/analise_draft.dart
lib/features/analise/presentation/providers/analise_provider.dart
lib/features/analise/presentation/providers/analise_provider.g.dart
lib/features/analise/presentation/providers/location_provider.dart
lib/features/analise/presentation/providers/pdf_parser_provider.dart
lib/features/analise/presentation/providers/pdf_parser_provider.g.dart
lib/features/analise/presentation/screens/analise_detail_screen.dart
lib/features/analise/presentation/screens/analise_form_page.dart
lib/features/analise/presentation/screens/analise_list_screen.dart
lib/features/analise/presentation/screens/analise_page.dart
lib/features/analise/presentation/screens/nova_analise_screen.dart
lib/features/analise/presentation/widgets/analise_calc_cell.dart
lib/features/analise/presentation/widgets/analise_card_widget.dart
lib/features/analise/presentation/widgets/analise_column_header.dart
lib/features/analise/presentation/widgets/analise_grid_card.dart
lib/features/analise/presentation/widgets/analise_input_cell.dart
lib/features/analise/presentation/widgets/analise_label_cell.dart
lib/features/analise/presentation/widgets/analise_resultado_table.dart
lib/features/analise/presentation/widgets/analise_section_header.dart
lib/features/analise/presentation/widgets/analise_section_row.dart
lib/features/analise/presentation/widgets/analise_table_widget.dart
lib/features/analise/presentation/widgets/filter_chips_widget.dart
lib/features/analise/presentation/widgets/importacao_bottom_sheet.dart
lib/features/analise/presentation/widgets/importacao_confianca_sheet.dart
lib/features/analise/presentation/widgets/localizacao_captura_widget.dart
lib/features/analise/presentation/widgets/map_preview_widget.dart
lib/features/analise/presentation/widgets/num_field_widget.dart
lib/features/analise/presentation/widgets/produtor_row_widget.dart
lib/features/analise/presentation/widgets/upload_pdf_widget.dart
lib/features/auth/presentation/cadastro/cadastro_controller.dart
lib/features/auth/presentation/cadastro/cadastro_controller.g.dart
lib/features/auth/presentation/cadastro/cadastro_page.dart
lib/features/auth/presentation/login/login_controller.dart
lib/features/auth/presentation/login/login_controller.g.dart
lib/features/auth/presentation/login/login_page.dart
lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.dart
lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.g.dart
lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart
lib/features/config/application/providers/demo_mode_provider.dart
lib/features/config/application/providers/perfil_assets_provider.dart
lib/features/config/application/providers/tabela_metricas_provider.dart
lib/features/config/data/datasources/demo_mode_hive_datasource.dart
lib/features/config/data/datasources/tabela_metricas_hive_datasource.dart
lib/features/config/domain/entities/tabela_metricas.dart
lib/features/config/domain/entities/tabela_metricas_defaults.dart
lib/features/config/presentation/base_dados/base_dados_detail_page.dart
lib/features/config/presentation/base_dados/base_dados_form_page.dart
lib/features/config/presentation/base_dados/base_dados_page.dart
lib/features/config/presentation/config_controller.dart
lib/features/config/presentation/config_page.dart
lib/features/config/presentation/feedback/feedback_page.dart
lib/features/config/presentation/providers/tabela_metricas_provider.dart
lib/features/config/presentation/tabela_metricas_page.dart
lib/features/crop/presentation/widgets/crop_phenology_tracker.dart
lib/features/culturas/providers/culturas_provider.dart
lib/features/culturas/screens/culturas_screen.dart
lib/features/culturas/widgets/nutrient_selector.dart
lib/features/culturas/widgets/result_card.dart
lib/features/culturas/widgets/source_dropdown.dart
lib/features/culturas/widgets/source_type_pills.dart
lib/features/historico/presentation/historico_page.dart
lib/features/lab/calibracao/data/calibracao_padrao.dart
lib/features/laboratorio/application/providers/laudo_provider.dart
lib/features/laboratorio/data/datasources/laudo_firestore_datasource.dart
lib/features/laboratorio/data/datasources/laudo_hive_datasource.dart
lib/features/laboratorio/data/models/laudo_recomendacao_model.dart
lib/features/laboratorio/data/repositories/laudo_repository_impl.dart
lib/features/laboratorio/domain/entities/laudo_recomendacao.dart
lib/features/laboratorio/domain/repositories/laudo_repository.dart
lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart
lib/features/laboratorio/presentation/calibracao/calibracao_state.dart
lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
lib/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart
lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart
lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
lib/features/laboratorio/presentation/lab_page.dart
lib/features/laboratorio/presentation/providers/laudo_provider.dart
lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart
lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart
lib/features/laboratorio/presentation/recomendacao/recomendacao_provider.dart
lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart
lib/features/laboratorio/services/laudo_pdf_generator.dart
lib/features/main/presentation/main_page.dart
lib/features/mapa/data/flutter_map_engine.dart
lib/features/mapa/data/google_map_engine.dart
lib/features/mapa/domain/map_engine.dart
lib/features/mapa/presentation/mapa_page.dart
lib/features/mapa/presentation/widgets/mapa_fab_modulos.dart
lib/features/mapa/presentation/widgets/modulos_bottom_sheet.dart
lib/features/mapa/providers/map_engine_provider.dart
lib/features/mapa/providers/mapa_analise_provider.dart
lib/features/mapa/providers/mapa_visivel_provider.dart
lib/firebase_options.dart
lib/main.dart
```

---

## ARQUIVOS MAIS LONGOS (TOP 15)

```
   47940 total
    3558 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
    2090 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
    1952 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/culturas_data.dart
    1732 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.freezed.dart
    1367 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/analise_model.freezed.dart
    1162 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
    1162 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
    1057 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
     993 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation/analise_data_contract.dart
     960 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/lab_pdf_parser.dart
     905 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart
     853 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart
     847 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
     814 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart
```

---

## RESULTADO flutter analyze

```
  meta 1.17.0 (1.18.2 available)
  mgrs_dart 2.0.0 (3.0.0 available)
  mocktail 1.0.4 (1.0.5 available)
  native_toolchain_c 0.17.5 (0.18.0 available)
  path_provider_android 2.2.22 (2.3.1 available)
  proj4dart 2.1.0 (3.0.0 available)
  riverpod 2.6.1 (3.2.1 available)
  riverpod_analyzer_utils 0.5.9 (0.5.10 available)
  riverpod_annotation 2.6.1 (4.0.2 available)
  riverpod_generator 2.6.4 (4.0.3 available)
  rx 0.4.0 (0.5.0 available)
  share_plus 10.1.4 (13.1.0 available)
  share_plus_platform_interface 5.0.2 (7.1.0 available)
  shelf_web_socket 2.0.1 (3.0.0 available)
  source_gen 2.0.0 (4.2.2 available)
  source_helper 1.3.7 (1.3.11 available)
  syncfusion_flutter_core 33.1.49 (33.2.3 available)
  syncfusion_flutter_pdf 33.1.49 (33.2.3 available)
  synchronized 3.4.0 (3.4.0+1 available)
  test_api 0.7.10 (0.7.11 available)
  unicode 0.3.1 (1.1.9 available)
  vector_math 2.2.0 (2.3.0 available)
  vm_service 15.0.2 (15.1.0 available)
  win32 5.15.0 (6.1.0 available)
Got dependencies!
1 package is discontinued.
79 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Analise...                                            
No issues found! (ran in 7.3s)
```

Erros: 0
Warnings: 0

---

## DETALHAMENTO POR BLOCO

### BLOCO 1 — SAÚDE DO PROJETO
1.1 Analyze
- Comando: `cd Analise && flutter analyze 2>&1 | tail -30` (executado em `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise`)
- Output real:
```
  meta 1.17.0 (1.18.2 available)
  mgrs_dart 2.0.0 (3.0.0 available)
  mocktail 1.0.4 (1.0.5 available)
  native_toolchain_c 0.17.5 (0.18.0 available)
  path_provider_android 2.2.22 (2.3.1 available)
  proj4dart 2.1.0 (3.0.0 available)
  riverpod 2.6.1 (3.2.1 available)
  riverpod_analyzer_utils 0.5.9 (0.5.10 available)
  riverpod_annotation 2.6.1 (4.0.2 available)
  riverpod_generator 2.6.4 (4.0.3 available)
  rx 0.4.0 (0.5.0 available)
  share_plus 10.1.4 (13.1.0 available)
  share_plus_platform_interface 5.0.2 (7.1.0 available)
  shelf_web_socket 2.0.1 (3.0.0 available)
  source_gen 2.0.0 (4.2.2 available)
  source_helper 1.3.7 (1.3.11 available)
  syncfusion_flutter_core 33.1.49 (33.2.3 available)
  syncfusion_flutter_pdf 33.1.49 (33.2.3 available)
  synchronized 3.4.0 (3.4.0+1 available)
  test_api 0.7.10 (0.7.11 available)
  unicode 0.3.1 (1.1.9 available)
  vector_math 2.2.0 (2.3.0 available)
  vm_service 15.0.2 (15.1.0 available)
  win32 5.15.0 (6.1.0 available)
Got dependencies!
1 package is discontinued.
79 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing Analise...                                            
No issues found! (ran in 7.3s)
```
- Status: ✅
- Observação: sem erros e sem warnings no output final do analyze.

1.2 Contagem de arquivos Dart
- Comandos: `find Analise/lib -name "*.dart" | wc -l` e `find Analise/lib -name "*.dart" | sort`
- Output real (contagem):
```
     202
```
- Output real (lista completa): ver seção **MAPA DE ARQUIVOS DART**
- Status: ✅
- Observação: 202 arquivos Dart em `lib/`.

1.3 Arquivos mais longos
- Comando: `find Analise/lib -name "*.dart" -exec wc -l {} + | sort -rn | head -15`
- Output real:
```
   47940 total
    3558 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
    2090 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
    1952 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/culturas_data.dart
    1732 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.freezed.dart
    1367 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/analise_model.freezed.dart
    1162 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
    1162 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
    1057 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
     993 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation/analise_data_contract.dart
     960 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/lab_pdf_parser.dart
     905 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart
     853 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart
     847 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
     814 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart
```
- Status: ⚠️
- Observação: há arquivos de alta complexidade (>1000 linhas).

1.4 Dependências instaladas
- Comando: `cat Analise/pubspec.yaml`
- Output real (integral):
```yaml
name: soloforte
description: App profissional de análise e recomendação de fertilidade de solo.
version: 1.0.1+65
publish_to: 'none'

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # ─── NAVEGAÇÃO ─────────────────────────────────────────────
  go_router: ^13.0.0

  # ─── GERÊNCIA DE ESTADO ────────────────────────────────────
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # ─── MODELOS IMUTÁVEIS ──────────────────────────────────────
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # ─── REDE ───────────────────────────────────────────────────
  dio: ^5.4.0

  # ─── CACHE LOCAL ────────────────────────────────────────────
  hive_flutter: ^1.1.0

  # ─── AUTENTICAÇÃO SEGURA ────────────────────────────────────
  flutter_secure_storage: ^9.0.0

  # ─── UI / VISUAL iOS ────────────────────────────────────────
  cupertino_icons: ^1.0.8
  flutter_animate: ^4.5.0
  flutter_markdown: ^0.7.3

  # ─── FORMULÁRIOS ────────────────────────────────────────────
  flutter_hooks: ^0.20.0

  # ─── LOCALIZAÇÃO (GPS) ──────────────────────────────────────
  geolocator: ^11.0.0
  geocoding: ^3.0.0

  # ─── FIREBASE ───────────────────────────────────────────────
  firebase_core: ^4.5.0
  cloud_firestore: ^6.1.3
  firebase_auth: ^6.2.0
  firebase_storage: ^13.1.0
  firebase_crashlytics: ^5.2.0
  firebase_performance: ^0.11.0
  image_picker: ^1.1.2

  # ─── UTILITÁRIOS ────────────────────────────────────────────
  intl: ^0.20.2
  uuid: ^4.3.0
  equatable: ^2.0.5
  hooks_riverpod: ^2.6.1
  path_provider: ^2.1.0
  share_plus: ^10.0.0
  file_picker: ^8.0.0

  # ─── PDF / LAUDO ────────────────────────────────────────────
  pdf: ^3.11.0
  syncfusion_flutter_pdf: ^33.1.49
  pdfx: ^2.6.0
  google_mlkit_text_recognition: ^0.14.0

  # ─── MAPA ───────────────────────────────────────────────────
  flutter_map: ^7.0.0
  latlong2: ^0.9.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

  # ─── GERAÇÃO DE CÓDIGO ──────────────────────────────────────
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.3.0

  # ─── QUALIDADE ──────────────────────────────────────────────
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
  fake_cloud_firestore: ^4.1.0+1
  firebase_auth_mocks: ^0.15.0

flutter:
  uses-material-design: true
  assets:
    - assets/soloforte.png
    - assets/images/
    - assets/icons/
    - assets/lab_data/
    - "PROMPT/dados referencias/"
```
- Status: ✅
- Observação: arquivo lido integralmente.

1.5 Versões Flutter/Dart
- Comandos: `flutter --version` e `dart --version`
- Output real:
```
Flutter 3.41.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision db50e20168 (4 weeks ago) • 2026-03-25 16:21:00 -0700
Engine • hash 5cdd32777948fa7a648fac915f8da7120ac7e97a (revision 425cfb54d0) (30 days ago) • 2026-03-25 20:14:42.000Z
Tools • Dart 3.11.4 • DevTools 2.54.2
Dart SDK version: 3.11.4 (stable) (Tue Mar 24 01:02:20 2026 -0700) on "macos_arm64"
```
- Status: ✅
- Observação: Flutter 3.41.6 / Dart 3.11.4 ativos.

### BLOCO 2 — ARQUITETURA E ESTRUTURA
2.1 Árvore completa de pastas
- Comando: `find Analise/lib -type d | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/config
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/services
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/theme
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/utils
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/formatters
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/base_dados
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/services
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/observability
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/entities
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/formulas
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/persistence
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/formatters
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data/datasources
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/domain
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/domain/entities
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/base_dados
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/feedback
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/perfil
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/screens
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/historico
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/historico/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/application
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/application/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/datasources
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/models
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/domain
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/domain/entities
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/domain/repositories
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/services
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/main
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/main/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/data
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/domain
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/widgets
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers
```
- Status: ✅
- Observação: estrutura organizada por `core/data/domain/features`.

2.2 Camada domain/
- Comando: `find Analise/lib/domain -type f -name "*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/analise_entity.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/analise_entity.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/analise_entity.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/calibracao_entity.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/citacao_calibracao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/lab_info.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/resultado_calagem.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/resultado_calagem.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/resultado_calagem.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/resultado_gesso.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/calagem_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/calcario_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/conversoes.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/fosforo_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/gesso_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/micronutrientes_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/potassio_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/calcario_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/calcario_input.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/fosforo_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/fosforo_input.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/gesso_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/types/gesso_input.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/analise_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/analise_model.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/analise_model.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/calibracao_profile.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/location_data_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/location_data_model.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/location_data_model.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/repositories/auth_repository.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/services/location_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.freezed.dart
```
- Status: ✅
- Observação: domínio presente com entidades, fórmulas e usecases.

2.3 Camada data/
- Comando: `find Analise/lib/data -type f -name "*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/base_dados/nc_por_referencia.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/base_dados/referencias_tecnicas_data.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/culturas_data.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local/calibracao_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local/calibracao_mock_db.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/analise_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/auth_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/calibracao_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/exata_brasil_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/exata_brasil_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/ibra_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/ibra_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/lab_detector.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/lab_pdf_parser.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/mb_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/mb_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/pdf_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/pdf_text_extractor.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/repositories/auth_repository_impl.dart
```
- Status: ✅
- Observação: data layer presente com local/remote/templates.

2.4 Camada presentation/
- Comando: `find Analise/lib/presentation -type f -name "*.dart" | sort`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ⚠️
- Observação: caminho `lib/presentation` não existe; UI está em `lib/features/**/presentation`.

2.5 Camada core/
- Comando: `find Analise/lib/core -type f -name "*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/config/app_config.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/services/app_observability.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/services/location_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/theme/app_colors.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/theme/app_text_styles.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/theme/app_theme.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/utils/location_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/utils/safra_utils.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_button.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_dropdown.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/formatters/digit_limit_formatter.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/nutriente_card.dart
```
- Status: ✅
- Observação: core contém router, tema, serviços e widgets compartilhados.

2.6 Features
- Comando: `find Analise/lib/features -type f -name "*.dart" 2>/dev/null | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/observability/analise_telemetry.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers/analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers/analise_telemetry_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/models/analise_solo_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/models/lab_template_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/models/produtor_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/repositories/analise_repository_impl.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/entities/analise_solo.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/entities/produtor.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/formulas/fosforo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/models/analise_draft.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/persistence/save_batch.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/repositories/analise_repository.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases/calcular_derivados_analise.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases/delete_analise_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases/get_analises_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases/parse_pdf_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/usecases/save_analise_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation/analise_data_contract.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/analise_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/analise_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/formatters/analise_number_formatter.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/models/analise_draft.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/location_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_form_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/nova_analise_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_calc_cell.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_column_header.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_grid_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_label_cell.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_section_header.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_section_row.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/filter_chips_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/importacao_bottom_sheet.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/importacao_confianca_sheet.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/localizacao_captura_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/map_preview_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/num_field_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/produtor_row_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/upload_pdf_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/demo_mode_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/perfil_assets_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/tabela_metricas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data/datasources/demo_mode_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data/datasources/tabela_metricas_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/domain/entities/tabela_metricas.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/domain/entities/tabela_metricas_defaults.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/base_dados/base_dados_detail_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/base_dados/base_dados_form_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/base_dados/base_dados_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/feedback/feedback_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/providers/culturas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/screens/culturas_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/nutrient_selector.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/result_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_dropdown.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_type_pills.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/historico/presentation/historico_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao/data/calibracao_padrao.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/application/providers/laudo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/datasources/laudo_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/datasources/laudo_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/models/laudo_recomendacao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/repositories/laudo_repository_impl.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/domain/entities/laudo_recomendacao.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/domain/repositories/laudo_repository.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/lab_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/services/laudo_pdf_generator.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/main/presentation/main_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/data/flutter_map_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/data/google_map_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/domain/map_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/widgets/mapa_fab_modulos.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/widgets/modulos_bottom_sheet.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/map_engine_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/mapa_analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/mapa_visivel_provider.dart
```
- Status: ✅
- Observação: 123 arquivos em features.

2.7 Router principal
- Comandos: `grep -r "GoRouter\|GoRoute\|ShellRoute\|StatefulShellRoute" Analise/lib --include="*.dart" -l` e `cat Analise/lib/core/router/app_router.dart`
- Output real (arquivos com router):
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart
```
- Output real (conteúdo do router):
```dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/auth/presentation/login/login_page.dart';

import 'package:soloforte/features/auth/presentation/cadastro/cadastro_page.dart';

import 'package:soloforte/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart';

import 'package:soloforte/features/main/presentation/main_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_form_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart'
    as feature_analise;
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/lab_page.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_page.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/lab_referencias_page.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart';
import 'package:soloforte/features/historico/presentation/historico_page.dart';
import 'package:soloforte/features/mapa/presentation/mapa_page.dart';
import 'package:soloforte/features/config/presentation/config_page.dart';

import 'package:soloforte/features/config/presentation/feedback/feedback_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_form_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_detail_page.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';
import 'package:soloforte/features/config/presentation/tabela_metricas_page.dart';
import 'package:soloforte/features/culturas/screens/culturas_screen.dart';

@visibleForTesting
String? resolveAppRedirect({
  required String path,
  required User? currentUser,
}) {
  final isAuthenticated = currentUser != null;

  final isAuthRoute = path == AppRoutes.login ||
      path == AppRoutes.cadastro ||
      path == AppRoutes.recuperarSenha;

  if (!isAuthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isAuthenticated && isAuthRoute) {
    return AppRoutes.analise;
  }

  if (path == AppRoutes.home) {
    return isAuthenticated ? AppRoutes.analise : AppRoutes.login;
  }

  return null;
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

class GoRouterAuthRefreshNotifier extends ChangeNotifier {
  GoRouterAuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      if (_isBootstrapping) {
        _isBootstrapping = false;
      }
      notifyListeners();
    });
  }

  bool _isBootstrapping = true;
  late final StreamSubscription<User?> _subscription;

  bool get isBootstrapping => _isBootstrapping;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final authRefresh = GoRouterAuthRefreshNotifier(auth.authStateChanges());
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.authBootstrap,
    debugLogDiagnostics: true,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;

      if (authRefresh.isBootstrapping) {
        if (path == AppRoutes.authBootstrap) {
          return null;
        }
        return AppRoutes.authBootstrap;
      }

      if (path == AppRoutes.authBootstrap) {
        return auth.currentUser != null ? AppRoutes.analise : AppRoutes.login;
      }

      return resolveAppRedirect(
        path: path,
        currentUser: auth.currentUser,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.authBootstrap,
        builder: (context, state) => const _AuthBootstrapPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: AppRoutes.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),
      GoRoute(
        path: AppRoutes.culturas,
        builder: (context, state) => const CulturasScreen(),
      ),
      GoRoute(
        path: AppRoutes.historico,
        redirect: (_, __) => AppRoutes.labHistorico,
      ),
      GoRoute(
        path: AppRoutes.baseDadosLegacyAlias,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDados,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDadosForm,
        redirect: (_, __) => AppRoutes.labRefNova,
      ),
      GoRoute(
        path: AppRoutes.baseDadosDetalhe,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.tabelaMetricas,
        redirect: (_, __) => AppRoutes.labRefMetricas,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analise,
                builder: (context, state) => const AnalisePage(),
                routes: [
                  GoRoute(
                    path: 'nova',
                    builder: (context, state) => const AnaliseFormPage(),
                  ),
                  GoRoute(
                    path: 'detalhe/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AnaliseDetailScreen(analiseId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          final container = ProviderScope.containerOf(context);
                          final lista = container
                                  .read(analiseNotifierProvider)
                                  .valueOrNull ??
                              [];
                          final feature_analise.AnaliseSolo? analise = lista
                              .cast<feature_analise.AnaliseSolo?>()
                              .firstWhere(
                                (a) => a?.id == id,
                                orElse: () => null,
                              );
                          if (analise == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              GoRouter.of(context).go(AppRoutes.analise);
                            });
                            return const SizedBox.shrink();
                          }
                          return NovaAnaliseScreen(analiseParaEditar: analise);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.lab,
                builder: (context, state) => const LabPage(),
                routes: [
                  GoRoute(
                    path: 'calibracao',
                    builder: (context, state) => const CalibracaoSeletorPage(),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => const CalibracaoPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recomendacao',
                    builder: (context, state) {
                      final extra = state.extra;
                      final analiseId = extra is String ? extra : null;
                      return RecomendacaoScreen(analiseId: analiseId);
                    },
                  ),
                  GoRoute(
                    path: 'referencias',
                    builder: (context, state) => const LabReferenciasPage(),
                    routes: [
                      GoRoute(
                        path: 'tecnicas',
                        builder: (context, state) => const BaseDadosPage(),
                      ),
                      GoRoute(
                        path: 'detalhes',
                        builder: (context, state) {
                          final ref = state.extra is ReferenciaTecnica
                              ? state.extra as ReferenciaTecnica
                              : null;
                          if (ref == null) {
                            return const BaseDadosPage();
                          }
                          return BaseDadosDetailPage(referencia: ref);
                        },
                      ),
                      GoRoute(
                        path: 'nova',
                        builder: (context, state) => const BaseDadosFormPage(),
                      ),
                      GoRoute(
                        path: 'metricas',
                        builder: (context, state) => const TabelaMetricasPage(),
                      ),
                      GoRoute(
                        path: 'absorcao-nutrientes',
                        builder: (context, state) =>
                            const AbsorcaoNutrientesReferenciaPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'historico',
                    builder: (context, state) => const HistoricoPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mapa,
                builder: (context, state) => MapaPage(
                  initialAnaliseId: state.uri.queryParameters['analiseId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.config,
                builder: (context, state) => const ConfigPage(),
                routes: [
                  GoRoute(
                    path: 'feedback',
                    builder: (context, state) => const FeedbackPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthBootstrapPage extends StatelessWidget {
  const _AuthBootstrapPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```
- Status: ✅
- Observação: router centralizado em `lib/core/router/app_router.dart`.

### BLOCO 3 — ESTADO (RIVERPOD)
3.1 Providers/notifiers
- Comando: `grep -r "StateNotifier\|Notifier\|riverpod\|@riverpod\|Provider" Analise/lib --include="*.dart" -l | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/auth_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/repositories/auth_repository_impl.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers/analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers/analise_telemetry_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/formulas/fosforo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/analise_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/analise_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/location_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/nova_analise_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/localizacao_captura_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/demo_mode_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/perfil_assets_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/tabela_metricas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/providers/culturas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/screens/culturas_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/nutrient_selector.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/result_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_dropdown.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_type_pills.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/historico/presentation/historico_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/application/providers/laudo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/main/presentation/main_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/widgets/modulos_bottom_sheet.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/map_engine_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/mapa_analise_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/mapa_visivel_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/main.dart
```
- Status: ✅
- Observação: Riverpod está amplamente adotado.

3.2 invalidateSelf / ref.invalidate
- Comando: `grep -rn "invalidateSelf\|ref\.invalidate" Analise/lib --include="*.dart"`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart:122:    ref.invalidateSelf();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/demo_mode_provider.dart:23:    ref.invalidateSelf();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart:28:    ref.invalidateSelf();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart:35:    ref.invalidateSelf();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart:40:    ref.invalidateSelf();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart:46:    ref.invalidateSelf();
```
- Status: 🚨
- Observação: `ref.invalidateSelf()` ocorre dentro de `salvar()` em `tabela_metricas_provider.dart:28` e `laudo_provider.dart:40`.

3.3 Uso de setState
- Comando: `grep -rn "setState" Analise/lib --include="*.dart" | grep -v "_test.dart"`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart:79:      setState(() => _isFocused = _focusNode.hasFocus);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart:184:                          setState(() => _isObscured = !_isObscured),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/nutriente_card.dart:95:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:72:          setState(() => _selectedFolderKey = null);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:93:                  onChanged: (val) => setState(() => _searchQuery = val),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:111:                  setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:122:                    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:189:                            setState(() => _selectedFolderKey = null),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:229:                          setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/importacao_confianca_sheet.dart:101:                setState(() => _selectedLabId = value);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:259:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart:98:        onFocusChange: (focused) => setState(() => _focused = focused),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart:124:                  setState(() {}); // para atualizar o destaque de vazio
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:112:                onClose: () => setState(() => _selectedPin = null),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:130:    setState(() => _cameraZoom = novoZoom);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:144:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:156:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:205:      setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:226:      setState(() => _selectedPin = null);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:243:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:237:                    setState(() => _linhas[i]['valor'] = novoValor);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:249:    setState(() => _salvando = true);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:275:      if (mounted) setState(() => _salvando = false);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart:103:                  setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:202:      // Usar SchedulerBinding para evitar setState durante build
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:205:          setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:263:            onToggle: () => setState(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:295:            onToggle: () => setState(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:308:                  setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:1370:                        setState(() => _expandedMicros[simbolo] = !aberto),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:1431:                                    onEditar: () => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:1479:                                    onEditar: () => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:1871:    setState(() => _editandoInline[campo] = false);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:241:            setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:260:            setState(() => _fosforoFonteNome = v);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:280:            setState(() => _fosforoModoAbsorcao = 'extracao');
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:289:            setState(() => _fosforoModoAbsorcao = 'exportacao');
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:364:                    onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:400:                onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:433:          onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:456:                onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:562:                onTap: () => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart:115:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart:126:    setState(() {}); // reconstrói label de equivalência
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:412:            setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:431:            setState(() => _potassioFonteNome = v);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:451:            setState(() => _potassioModoAbsorcao = 'extracao');
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:460:            setState(() => _potassioModoAbsorcao = 'exportacao');
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:533:                    onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:562:          onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:580:          onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:603:          onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:617:          onChanged: (v) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:843:                onTap: () => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart:333:    setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart:357:            onSelect: (a) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart:371:            onSelect: (p) => setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:113:                          setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:137:                          setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:531:    setState(() => _gerando = true);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:548:      setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:555:      setState(() => _gerando = false);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:616:    setState(() => _salvando = true);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:641:      if (mounted) setState(() => _salvando = false);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:646:    setState(() => _exportando = true);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:661:      if (mounted) setState(() => _exportando = false);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2695:      onTap: () => setState(() => _section = section),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2742:              setState(() {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2757:              setState(() => _selectedSource = value);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2770:              setState(() => _selectedNutrient = value);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2785:                    setState(() => _selectedDataType = value);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2801:                    setState(() => _viewMode = value);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:2831:            onChanged: (_) => setState(() {}),
```
- Status: ⚠️
- Observação: coexistência de `setState` com Riverpod em telas e widgets.

3.4 StatefulWidget vs ConsumerWidget
- Comandos: `grep -rn "extends StatefulWidget" ...` e `grep -rn "extends ConsumerWidget\|extends ConsumerStatefulWidget" ...`
- Output real (StatefulWidget):
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_button.dart:6:class AppButton extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart:7:class AppInput extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/nutriente_card.dart:8:class NutrienteCard extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/importacao_confianca_sheet.dart:5:class ImportacaoConfiancaSheet extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:205:class AnaliseResultadoTable extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:522:class _ValueCell extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart:8:class AnaliseInputCell extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:172:class _TabelaEditorPage extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:287:class _LinhaEditor extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart:23:class CropPhenologyTracker extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart:10:class CalibracaoHeaderCard extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart:163:class PotassioCardWidget extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart:318:class RecomendacaoPage extends StatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart:8:class AbsorcaoNutrientesReferenciaPage extends StatefulWidget {
```
- Output real (Consumer*):
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:11:class AnaliseDetailScreen extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/nova_analise_screen.dart:26:class NovaAnaliseScreen extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:13:class AnaliseListScreen extends ConsumerStatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/localizacao_captura_widget.dart:9:class LocalizacaoCaptura extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:10:class MapaPage extends ConsumerStatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/widgets/modulos_bottom_sheet.dart:9:class ModulosBottomSheet extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart:13:class TabelaMetricasPage extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart:246:class ConfigPage extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/config_page.dart:457:class _IdentidadeVisualCard extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/historico/presentation/historico_page.dart:13:class HistoricoPage extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/screens/culturas_screen.dart:10:class CulturasScreen extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_dropdown.dart:5:class SourceDropdown extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/nutrient_selector.dart:6:class NutrientSelector extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/source_type_pills.dart:6:class SourceTypePills extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/result_card.dart:8:class ResultCard extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/culturas/widgets/result_card.dart:94:class _DataModeToggle extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart:19:class CalibracaoPage extends ConsumerStatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart:32:class FosforoCardWidget extends ConsumerStatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart:18:class CalibracaoSeletorPage extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart:8:class RecomendacaoHeader extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart:100:class AssinaturaWidget extends ConsumerWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:26:class RecomendacaoScreen extends ConsumerStatefulWidget {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/main/presentation/main_page.dart:7:class MainPage extends ConsumerWidget {
```
- Status: ⚠️
- Observação: arquitetura híbrida (14 Stateful x 23 Consumer*).

### BLOCO 4 — FÓRMULAS AGRONÔMICAS
4.1 Arquivos de fórmulas
- Comando: `find Analise/lib/domain -name "*formula*" -o -name "*engine*" -o -name "*calculo*" -o -name "*recomendacao*" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/calagem_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/calcario_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/fosforo_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/gesso_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/micronutrientes_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/formulas/potassio_formula.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/recomendacao_model.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.freezed.dart
```
- Status: ✅
- Observação: fórmulas e engine centralizadas em domain/.

4.2 RecomendacaoEngine
- Comandos: `find Analise/lib -name recomendacao_engine.dart` e `wc -l .../recomendacao_engine.dart`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
    1162 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/usecases/recomendacao_engine.dart
```
- Status: ⚠️
- Observação: `recomendacao_engine.dart` com 1162 linhas (alto acoplamento).

4.3 Vazamento de fórmula na UI
- Comando solicitado: `grep ... Analise/lib/presentation/lab/recomendacao/recomendacao_screen.dart`
- Output real (caminho solicitado):
```
NÃO ENCONTRADO
NÃO ENCONTRADO
```
- Output real (caminho existente no projeto):
```
     767 /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
14:import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
```
- Status: 🚨
- Observação: arquivo existente importa `recomendacao_engine.dart` direto na UI (vazamento de fórmula), mesmo com 767 linhas (<800).

4.4 Conversão de Potássio (391)
- Comando: `grep -rn "391\|k_mgdm3\|potassio.*391\|K.*391" Analise/lib --include="*.dart" | head -10`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:153:          dynamic kRaw = item['k_mgdm3'] ?? item['k'];
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:157:              (item.containsKey('k_mgdm3') || (kVal > 10))) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:159:            kVal = kVal / 391.0;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation/analise_data_contract.dart:796:      normalizedValue = parsed / 391.0;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:87:  _UnitStep('cmolc/dm³', 1.0 / 391, decimals: 3),
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:642:      case 'k_mgdm3':
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_import_service.dart:79:    // - JSON novo: k_mgdm3 (mg/dm³) -> converte para cmolc/dm³
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_import_service.dart:82:    final kRawMgDm3 = toDouble(value('k_mgdm3'));
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/mb_import_service.dart:49:    // K: mg/dm³ → cmolc/dm³ (÷ 391)
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/mb_import_service.dart:50:    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;
```
- Status: ⚠️
- Observação: divisão por 391 aparece também fora de parser (ex.: `analise_data_contract.dart:796`, `analise_resultado_table.dart:87`).

4.5 Profundidade padrão
- Comando: `grep -rn '"0-20"\|profundidade.*default\|profundidade.*padrao' ...`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/entities/analise_solo.dart:50:  final String profundidade;       // ex: "0-20"
```
- Status: ✅
- Observação: fallback `"0-20"` encontrado.

### BLOCO 5 — PARSERS DE PDF
5.1 Parsers existentes
- Comando: `find Analise/lib -name "*parser*" -o -name "*exata*" -o -name "*mbagro*" -o -name "*ibra*" -o -name "*sellar*" ...`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local/calibracao_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local/calibracao_mock_db.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/calibracao_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/exata_brasil_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/exata_brasil_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/ibra_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/ibra_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/lab_pdf_parser.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_import_service.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/lab_templates/sellar_template.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/calibracao_entity.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/entities/citacao_calibracao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/domain/models/calibracao_profile.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/pdf_parser_provider.g.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao/data/calibracao_padrao.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart
```
- Status: ✅
- Observação: serviços de importação Exata/IBRA/Sellar encontrados; MB está como `mb_import_service.dart`.

5.2 Lista dos 4 parsers esperados
- Comando: `find Analise/lib -name "*.dart" | xargs grep -l "ExataBrasil\|MB.Agro\|IBRA\|Sellar"`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ⚠️
- Observação: comando não retornou arquivos; nomenclatura no código diverge do padrão de busca.

5.3 Campos mapeados por parser
- Comando base: `grep -n "profundidade\|argila\|ph\|k_mgdm3\|calcio\|magnesio\|fosforo" [CAMINHO_PARSER] | head -20`
- Output real (exata_brasil_import_service.dart):
```
50:    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;
100:      profundidade: _normalizarProfundidade(raw('profundidade')),
102:      argila: toDouble(raw('argila')),
105:      phAgua: null,
106:      phSmp: toDouble(raw('phSmp')),
107:      phCaCl2: toDouble(raw('phCaCl2')),
```
- Output real (ibra_import_service.dart):
```
108:      profundidade: _normalizarProfundidade(raw('profundidade')),
110:      argila: toDouble(raw('argila')),
113:      phAgua: null,
114:      phSmp: toDouble(raw('phSmp')),
115:      phCaCl2: toDouble(raw('phCaCl2')),
```
- Output real (mb_import_service.dart):
```
50:    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;
61:    final argilaGkg = toDouble(raw('argila_pct')) != null
62:        ? toDouble(raw('argila_pct'))! * 10.0
100:      profundidade: _normalizarProfundidade(raw('profundidade')),
102:      argila: argilaGkg,
105:      phAgua: null,
106:      phSmp: null,
107:      phCaCl2: toDouble(raw('phCaCl2')),
```
- Output real (sellar_import_service.dart):
```
79:    // - JSON novo: k_mgdm3 (mg/dm³) -> converte para cmolc/dm³
82:    final kRawMgDm3 = toDouble(value('k_mgdm3'));
96:      profundidade: _normalizarProfundidade(value('profundidade')),
98:      argila: toDouble(value('argila')),
101:      phAgua: toDouble(value('phAgua')),
102:      phSmp: toDouble(value('phSmp')),
103:      phCaCl2: toDouble(value('phCaCl2')),
```
- Output real (lab_pdf_parser.dart):
```
49:      String? profundidade,
55:          'profundidade': profundidade ?? '0-20',
64:      if ((sample['profundidade'] as String).trim().isEmpty &&
65:          profundidade != null &&
66:          profundidade.trim().isNotEmpty) {
67:        sample['profundidade'] = profundidade.trim();
85:          header.contains('fe (meh)') && header.contains('argila');
97:              'phCaCl2': _toDouble(parsed.values[0]),
103:              'k_mgdm3': _toDouble(parsed.values[7]),
106:            profundidade: parsed.profundidade,
125:            profundidade: parsed.profundidade,
141:              'argila': _toDouble(parsed.values[7]),
144:            profundidade: parsed.profundidade,
157:              'argila': _toDouble(parsed.values[4]),
162:            profundidade: parsed.profundidade,
175:            profundidade: parsed.profundidade,
262:                'profundidade': '${m.group(2) ?? ''}-${m.group(3) ?? ''}',
309:          'profundidade': meta['profundidade'] ?? '0-20',
314:          'phCaCl2': _toDouble(values[4]),
315:          'phSmp': _toDouble(values[5]),
```
- Status: ✅
- Observação: campos críticos (profundidade, argila, pH, k_mgdm3) estão mapeados.

### BLOCO 6 — FIREBASE E DADOS
6.1 Firebase Options
- Comando: `cat .../firebase_options.dart | grep -E "projectId|apiKey|MOCK" | head -10`
- Output real:
```
    apiKey: 'AIzaSyDF8NPxIz0rw_bZ4xjlIzJkgo7xm3WK4qw',
    projectId: 'soloforte-106c8',
    apiKey:
    projectId: 'soloforte-106c8',
```
- Status: ⚠️
- Observação: não foi encontrado `MOCK_API_KEY`; há chaves Firebase no arquivo gerado.

6.2 Datasources ativos vs mocks
- Comando: `grep -rn "AnaliseLocalDatasource\|MockDatasource\|mockData\|listaLocal" ... | head -15`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:67:class AnaliseLocalDatasource implements AnaliseDataSource {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:80:  AnaliseLocalDatasource({
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:15:    AutoDisposeProvider<AnaliseLocalDatasource>.internal(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:27:typedef AnaliseLocalDatasourceRef
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:28:    = AutoDisposeProviderRef<AnaliseLocalDatasource>;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart:19:AnaliseLocalDatasource analiseLocalDatasource(AnaliseLocalDatasourceRef ref) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart:20:  return AnaliseLocalDatasource();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart:91:    final localDs = AnaliseLocalDatasource(useAssetSeed: true);
```
- Status: ⚠️
- Observação: provider ainda instancia `AnaliseLocalDatasource` (fluxo local ativo).

6.3 Firestore datasources
- Comando: `find Analise/lib/data -name "*firestore*" -o -name "*firebase*" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/analise_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/calibracao_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart
```
- Status: ✅
- Observação: datasources Firestore presentes.

6.4 Regras Firestore
- Comando: `find . -name firestore.rules`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/firestore.rules
```
- Status: ✅
- Observação: regras versionadas existem.

6.5 Hive storage local
- Comando: `grep -rn "Hive\|HiveBox\|openBox" Analise/lib --include="*.dart" -l | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/data/datasources/local/calibracao_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/application/providers/demo_mode_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data/datasources/demo_mode_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/data/datasources/tabela_metricas_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/lab/calibracao/data/calibracao_padrao.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/datasources/laudo_firestore_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/datasources/laudo_hive_datasource.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/models/laudo_recomendacao_model.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/data/repositories/laudo_repository_impl.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/main.dart
```
- Status: ✅
- Observação: uso de Hive identificado em múltiplos módulos.

### BLOCO 7 — NAVEGAÇÃO
7.1 Número de abas no MainPage
- Comando solicitado (caminho antigo): `.../lib/presentation/main/main_page.dart`
- Output real (caminho solicitado):
```
NÃO ENCONTRADO
0
```
- Output real (caminho existente no projeto):
```
19:      bottomNavigationBar: Padding(
Labels de abas encontrados:
45:                label: 'Análise',
52:                label: 'Lab',
59:                label: 'Mapa',
66:                label: 'Config',
```
- Status: ✅
- Observação: 4 abas reais (Análise, Lab, Mapa, Config); sem divergência de 5 abas.

7.2 Rotas definidas
- Comando: `grep -rn "AppRoutes\.\|GoRoute\|path:" Analise/lib/core --include="*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:32:  @Deprecated('Use AppRoutes.labRefTecnicas')
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:34:  @Deprecated('Use AppRoutes.labRefTecnicas')
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:36:  @Deprecated('Use AppRoutes.labRefNova')
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:38:  @Deprecated('Use AppRoutes.labRefDetalhes')
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:3:  AppRoutes._();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:42:  @Deprecated('Use AppRoutes.labRefMetricas')
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:105:        if (path == AppRoutes.authBootstrap) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:108:        return AppRoutes.authBootstrap;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:111:      if (path == AppRoutes.authBootstrap) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:112:        return auth.currentUser != null ? AppRoutes.analise : AppRoutes.login;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:116:        path: path,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:121:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:122:        path: AppRoutes.authBootstrap,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:125:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:126:        path: AppRoutes.login,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:129:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:130:        path: AppRoutes.cadastro,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:133:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:134:        path: AppRoutes.recuperarSenha,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:137:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:138:        path: AppRoutes.culturas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:141:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:142:        path: AppRoutes.historico,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:143:        redirect: (_, __) => AppRoutes.labHistorico,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:145:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:146:        path: AppRoutes.baseDadosLegacyAlias,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:147:        redirect: (_, __) => AppRoutes.labRefTecnicas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:149:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:150:        path: AppRoutes.baseDados,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:151:        redirect: (_, __) => AppRoutes.labRefTecnicas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:153:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:154:        path: AppRoutes.baseDadosForm,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:155:        redirect: (_, __) => AppRoutes.labRefNova,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:157:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:158:        path: AppRoutes.baseDadosDetalhe,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:159:        redirect: (_, __) => AppRoutes.labRefTecnicas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:161:      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:162:        path: AppRoutes.tabelaMetricas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:163:        redirect: (_, __) => AppRoutes.labRefMetricas,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:171:              GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:172:                path: AppRoutes.analise,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:175:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:176:                    path: 'nova',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:179:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:180:                    path: 'detalhe/:id',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:186:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:187:                        path: 'editar',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:203:                              GoRouter.of(context).go(AppRoutes.analise);
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:218:              GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:219:                path: AppRoutes.lab,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:222:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:223:                    path: 'calibracao',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:226:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:227:                        path: 'editar',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:232:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:233:                    path: 'recomendacao',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:240:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:241:                    path: 'referencias',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:244:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:245:                        path: 'tecnicas',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:248:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:249:                        path: 'detalhes',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:260:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:261:                        path: 'nova',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:264:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:265:                        path: 'metricas',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:268:                      GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:269:                        path: 'absorcao-nutrientes',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:275:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:276:                    path: 'historico',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:285:              GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:286:                path: AppRoutes.mapa,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:295:              GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:296:                path: AppRoutes.config,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:299:                  GoRoute(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:300:                    path: 'feedback',
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:47:  final isAuthRoute = path == AppRoutes.login ||
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:48:      path == AppRoutes.cadastro ||
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:49:      path == AppRoutes.recuperarSenha;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:52:    return AppRoutes.login;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:56:    return AppRoutes.analise;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:59:  if (path == AppRoutes.home) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:60:    return isAuthenticated ? AppRoutes.analise : AppRoutes.login;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:70:class GoRouterAuthRefreshNotifier extends ChangeNotifier {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:71:  GoRouterAuthRefreshNotifier(Stream<User?> stream) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:92:final routerProvider = Provider<GoRouter>((ref) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:94:  final authRefresh = GoRouterAuthRefreshNotifier(auth.authStateChanges());
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:97:  return GoRouter(
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:98:    initialLocation: AppRoutes.authBootstrap,
```
- Status: ✅
- Observação: rotas centralizadas em `app_routes.dart` e `app_router.dart`.

7.3 Parâmetros via extra
- Comando: `grep -rn "state\.extra\|extra:" Analise/lib --include="*.dart" | grep -v "_test.dart"`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:235:                      final extra = state.extra;
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:251:                          final ref = state.extra is ReferenciaTecnica
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:252:                              ? state.extra as ReferenciaTecnica
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:135:                      extra: analise.id,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/base_dados/base_dados_page.dart:43:                      extra: ref,
```
- Status: ⚠️
- Observação: há uso de `state.extra`/`extra:` no router e telas; risco de fragilidade de navegação.

### BLOCO 8 — UI E DESIGN SYSTEM
8.1 AppTextStyles.title
- Comando: `grep -rn "AppTextStyles.title" Analise/lib --include="*.dart`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ✅
- Observação: nenhum uso encontrado; erro de compilação específico não reproduzido.

8.2 Tokens do design system
- Comandos: `cat ...app_colors.dart | head -40` e `cat ...app_text_styles.dart | head -40`
- Output real (app_colors):
```
import 'package:flutter/material.dart';

/// Paleta de cores do SoloForte — iOS/Apple Design System
class AppColors {
  AppColors._();

  // ─── PRIMÁRIAS ────────────────────────────────────────────
  static const Color primary = Color(0xFF007AFF);      // Azul iOS
  static const Color primaryDark = Color(0xFF0051D5);  // Azul escuro (gradient)

  // ─── BACKGROUNDS ─────────────────────────────────────────
  static const Color bgPrimary = Color(0xFFFFFFFF);    // Branco
  static const Color bgSecondary = Color(0xFFF5F5F7);  // Cinza muito claro
  static const List<Color> bgGradient = [
    Color(0xFFF5F5F7),
    Color(0xFFE5E5E7),
  ];

  // ─── TEXTO ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1D1D1F);    // Preto suave
  static const Color textSecond = Color(0xFF86868B);     // Cinza médio
  static const Color textTertiary = Color(0xFFC7C7CC);   // Cinza claro

  // ─── ESTADO ──────────────────────────────────────────────
  static const Color success = Color(0xFF34C759);        // Verde iOS
  static const Color error = Color(0xFFFF3B30);          // Vermelho iOS
  static const Color warning = Color(0xFFFF9500);        // Laranja iOS
  static const Color bgSuccess = Color(0xFFE8F5E9);      // Fundo positivo
  static const Color bgError = Color(0xFFFFEBEE);        // Fundo negativo
  static const Color bgWarning = Color(0xFFFFF3E0);      // Fundo alerta

  // ─── BORDAS ──────────────────────────────────────────────
  static const Color border = Color(0xFFD1D1D6);         // Borda padrão
  static const Color borderSoft = Color(0xFFE5E5E7);     // Borda suave

  // ─── NUTRIENTES (cards de calibração) ───────────────────
  static const Color calcario = Color(0xFF5AC8FA);       // Azul claro
  static const Color gesso = Color(0xFFFFCC00);          // Amarelo
  static const Color potassio = Color(0xFFFF9500);       // Laranja
  static const Color fosforo = Color(0xFFFF3B30);        // Vermelho
```
- Output real (app_text_styles):
```
import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Hierarquia tipográfica do SoloForte — iOS/Apple Design System
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle _base = TextStyle(
    fontFamily: '.SF Pro Text', // iOS nativo; Roboto como fallback Android
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Títulos de seção (uppercase, discreto) — 12px, w500
  static final TextStyle sectionLabel = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecond,
  );

  /// Texto normal — 15px, w400
  static final TextStyle body = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  /// Labels e subtítulos — 14px, w500
  static final TextStyle label = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Valores destacados (resultados, ROI) — 17px, w600
  static final TextStyle value = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

```
- Status: ✅
- Observação: tokens de cor e tipografia presentes.

8.3 Widgets compartilhados
- Comando: `find Analise/lib/core/widgets -name "*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_button.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_dropdown.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/formatters/digit_limit_formatter.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/nutriente_card.dart
```
- Status: ✅
- Observação: 6 widgets utilitários compartilhados encontrados.

8.4 Validação de campos
- Comando solicitado: `grep -rn ... Analise/lib/presentation ...`
- Output real (caminho solicitado):
```
NÃO ENCONTRADO
```
- Evidência adicional (regra específica):
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart:479:    if (state.analises.isEmpty) {
```
- Status: ⚠️
- Observação: caminho `lib/presentation` inexistente; evidência encontrada de bloqueio por `state.analises.isEmpty`, mas validação de unicidade total fica inconclusiva com o comando solicitado.

### BLOCO 9 — BUILD E CI/CD
9.1 Codemagic
- Comando: `cat codemagic.yaml | grep -E "working_directory|flutter|scripts|branch" | head -20`
- Output real:
```
      flutter: stable
    scripts:
        script: flutter pub get
        script: flutter analyze
        script: flutter test
          flutter clean
          flutter build ios --release --no-codesign --build-name="${BUILD_NAME}" --build-number="${BUILD_NUMBER}"
      - flutter_drive.log
```
- Status: ⚠️
- Observação: `working_directory: Analise` não foi encontrado.

9.2 Info.plist Export Compliance
- Comando: `grep -A2 "ITSAppUsesNonExemptEncryption" .../Info.plist`
- Output real:
```
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
</dict>
```
- Status: ✅
- Observação: flag presente com `<false/>`.

9.3 Versão do app
- Comando: `grep "version:" Analise/pubspec.yaml`
- Output real:
```
version: 1.0.1+65
```
- Status: ✅
- Observação: versão atual definida.

9.4 Build number
- Comando: `grep "version:" ... | grep -oE "\+[0-9]+"`
- Output real:
```
+65
```
- Status: ✅
- Observação: build number atual identificado.

### BLOCO 10 — TESTES
10.1 Arquivos de teste
- Comando: `find Analise/test -name "*.dart" | sort`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/core/config/app_config_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/core/router/app_router_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/datasources/remote/auth_datasource_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/exata_brasil_import_service_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/ibra_import_service_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/lab_detector_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/pdf_import_ground_truth_local_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/pdf_import_pipeline_local_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/pdf_import_service_telemetry_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/mb_import_service_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/repositories/auth_repository_impl_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/sellar_import_service_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/calagem_engine_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/calcario_formula_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/fosforo_formula_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/gesso_engine_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/micronutrientes_engine_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/formulas/potassio_formula_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/usecases/calcular_recomendacao_usecase_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/domain/usecases/recomendacao_engine_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/application/observability/analise_telemetry_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/application/providers/analise_telemetry_provider_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/data/datasources/analise_firestore_datasource_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/data/datasources/analise_local_datasource_batch_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/domain/validation/analise_data_contract_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/integration/nova_analise_flow_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/controllers/nova_analise_controller_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/formatters/analise_number_formatter_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/models/analise_draft_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/providers/analise_provider_policy_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/screens/nova_analise_screen_golden_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/analise/presentation/widgets/analise_table_widget_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/auth/presentation/login/login_page_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/historico/presentation/historico_page_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/laboratorio/data/laudo_repository_impl_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/laboratorio/presentation/laudo_notifier_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/features/laboratorio/presentation/recomendacao/recomendacao_screen_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/main_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/presentation/login_controller_test.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/support/analise_test_factories.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/support/analise_test_harness.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/widget_test.dart
```
- Status: ✅
- Observação: 42 arquivos de teste encontrados.

10.2 Cobertura de fórmulas (quantidade de asserts/tests)
- Comando: `grep -rn "expect\|test(" Analise/test --include="*.dart" | wc -l`
- Output real:
```
     710
```
- Status: ✅
- Observação: 710 ocorrências de `expect`/`test(`.

10.3 Testes passando
- Comando: `cd Analise && flutter test 2>&1 | tail -10`
- Output real:
```
00:08 +251: /Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/pdf_import_ground_truth_local_test.dart: ground truth local: aceite P0 com 20+ PDFs reais e 95%+ de sucesso
=== Ground Truth Import Report ===
Total esperado no lote: 24
Meta: total >= 20 | por lab >= 5 | global >= 95% | por lab >= 90%
[lab=sellar] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=exata_brasil] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=ibra] attempted=6 ok=6 failed=0 successRate=100.00%
[lab=mb] attempted=6 ok=6 failed=0 successRate=100.00%
[global] attempted=24 ok=24 failed=0 successRate=100.00%
00:09 +252: All tests passed!
```
- Status: ✅
- Observação: suíte finaliza com `All tests passed!`.

### BLOCO 11 — SEGURANÇA E QUALIDADE
11.1 Print statements
- Comandos: `grep -rn "print(" ... | wc -l` e `... | head -10`
- Output real:
```
       0
NÃO ENCONTRADO
```
- Status: ✅
- Observação: 0 prints em produção.

11.2 Chaves hardcoded
- Comando: `grep -rn "apiKey\|secret\|password\|senha" ... | grep -v "firebase_options\|_test.dart" | head -10`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:18:  static const String esqueceuSenha = 'Recuperar senha';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:21:  static const String senha = 'Senha';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:22:  static const String confirmarSenha = 'Confirmar senha';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:46:  static const String senhaMinimo6 = 'Mínimo 6 caracteres';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:47:  static const String senhaMinimo8 = 'Mínimo 8 caracteres';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_strings.dart:48:  static const String senhasNaoCoincidem = 'As senhas não coincidem';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/constants/app_routes.dart:7:  static const String recuperarSenha = '/recuperar-senha';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:12:import 'package:soloforte/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart';
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/providers/analise_telemetry_provider.dart:26:            apiKey: AppConfig.analiseTelemetryApiKey,
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/application/observability/analise_telemetry.dart:44:  final String? _apiKey;
```
- Status: ⚠️
- Observação: hits incluem textos/rotas de senha e referência a apiKey de configuração; sem segredo explícito no recorte.

11.3 Conta demo
- Comando: `grep -rn "demo@cadernosolo\|demo@\|conta.*demo" Analise/lib --include="*.dart" | head -5`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ⚠️
- Observação: não foram encontradas referências à conta demo solicitada.

11.4 Imports não utilizados
- Comando: `cd Analise && flutter analyze 2>&1 | grep "unused_import" | wc -l`
- Output real:
```
       0
```
- Status: ✅
- Observação: 0 ocorrências de unused_import.

### BLOCO 12 — PONTOS PENDENTES CONHECIDOS
12.1 GPS hardcoded
- Comando: `grep -rn "São Paulo\|-23.5\|-46.6\|coordenadas.*fixas\|lat.*fixed" ...`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_dropdown.dart:129:  const AppDropdownItem(value: 'SP', label: 'São Paulo'),
```
- Status: ⚠️
- Observação: houve match de `São Paulo` em dropdown; coordenadas fixas não apareceram no recorte.

12.2 Google Maps stub
- Comando: `grep -rn "GoogleMapEngine\|mapEngineProvider\|MapEngine" ... | head -10`
- Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/map_engine_provider.dart:5:final mapEngineProvider = Provider<MapEngine>((ref) {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/map_engine_provider.dart:6:  return FlutterMapEngine();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/providers/map_engine_provider.dart:7:  // Futuramente: return GoogleMapEngine();
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/data/google_map_engine.dart:6:class GoogleMapEngine implements MapEngine {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/data/flutter_map_engine.dart:7:class FlutterMapEngine implements MapEngine {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/domain/map_engine.dart:4:abstract class MapEngine {
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/mapa/presentation/mapa_page.dart:51:    final engine = ref.watch(mapEngineProvider);
```
- Status: ⚠️
- Observação: stub de `GoogleMapEngine` existe, com provider retornando `FlutterMapEngine`.

12.3 Calibração Seletor — AppTextStyles.title
- Comando: `grep -n "AppTextStyles.title" Analise/lib/presentation/lab/calibracao/calibracao_seletor_page.dart`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ✅
- Observação: sem ocorrência no caminho solicitado.

12.4 Route B1 — state.extra
- Comando: `grep -rn "state\.extra" Analise/lib/presentation/analise --include="*.dart" | head -10`
- Output real:
```
NÃO ENCONTRADO
```
- Status: ✅
- Observação: sem ocorrência no caminho solicitado.

---

## ITENS CRÍTICOS CONSOLIDADOS 🚨

1. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart:28` — `ref.invalidateSelf()` dentro de `salvar()`.
2. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart:40` — `ref.invalidateSelf()` dentro de `salvar()`.
3. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:14` — UI importa `recomendacao_engine.dart` diretamente.

---

## ITENS DE ATENÇÃO ⚠️

1. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib` — caminho `lib/presentation` não existe (estrutura atual em `lib/features/**/presentation`).
2. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/domain/validation/analise_data_contract.dart:796` — conversão ÷391 fora de parser.
3. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:87` — conversão de unidade vinculada a 391 em camada UI.
4. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/providers/analise_provider.dart:91` — datasource local em uso (`useAssetSeed: true`).
5. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/router/app_router.dart:235` — uso de `state.extra`.
6. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/codemagic.yaml` — `working_directory: Analise` não encontrado.
7. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib` — conta demo `demo@cadernosolo.com.br` não encontrada por grep.

---

## ESTADO DOS PONTOS PENDENTES

| Pendência | Arquivo | Status |
|-----------|---------|--------|
| GPS hardcoded | NovaAnaliseScreen | ✅ Corrigido (nenhuma coordenada fixa encontrada; apenas string de estado em dropdown) |
| AppTextStyles.title (CalibracaoSeletor) | calibracao_seletor_page.dart | ✅ Corrigido (sem ocorrência) |
| state.extra frágil (rota B1) | analise_edit_route | ✅ Corrigido no caminho auditado (sem ocorrência em lib/presentation/analise) |
| 5 abas vs 4 esperadas | main_page.dart | ✅ Corrigido (4 abas reais) |
| Mock vs Firestore real | AnaliseListScreen | 🔄 Ainda pendente (fluxo local ainda encontrado) |
| Firestore rules ausentes | firestore.rules | ✅ Corrigido (arquivo presente) |
| Print statements | lib/ | 0 encontrados |
| invalidateSelf no salvar() | providers de config/lab | 🔄 Ainda pendente (2 ocorrências) |
| recomendacao_screen.dart (>800 linhas) | recomendacao_screen.dart | 🔄 Ainda pendente (767 linhas, porém com import direto de engine) |

---

## RECOMENDAÇÃO DE PRÓXIMOS PASSOS

1. Remover `ref.invalidateSelf()` de métodos `salvar()` e migrar para atualização de estado explícita pós-sucesso.
2. Extrair a dependência de `recomendacao_engine` da UI para camada application/usecase e injetar resultado pronto na tela.
3. Centralizar conversão de K (÷391) em um único ponto de domínio para eliminar duplicação entre parser/validação/UI.
4. Revisar bootstrap de dados para priorizar Firestore em produção e limitar `AnaliseLocalDatasource` a fallback/offline controlado.
5. Ajustar `codemagic.yaml` para declarar explicitamente o diretório de trabalho esperado no pipeline.
6. Definir e versionar credenciais/fluxo de conta demo para revisão Apple (sem hardcode sensível).
