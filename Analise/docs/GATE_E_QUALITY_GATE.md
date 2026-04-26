# Gate E - Quality Gate no CI

Este documento descreve o gate automatico de qualidade/cobertura usado no CI.

## Execucao

- Script principal: `./tool/quality_gate.sh`
- Parser de cobertura: `./tool/coverage_gate.py`
- Pipeline Codemagic: `codemagic.yaml`

## O que bloqueia o pipeline

1. Violacao de fronteira `domain -> presentation/application`.
2. Import cruzado `presentation` entre features.
3. `flutter analyze` com erro.
4. Falha na suite critica com `--coverage`.
5. Thresholds de cobertura abaixo do minimo.

## Thresholds padrao (critical files)

- `lib/main.dart`: 25%
- `lib/core/router/app_router.dart`: 50%
- `lib/features/auth/presentation/login/login_controller.dart`: 85%
- `lib/data/datasources/remote/auth_datasource.dart`: 80%
- `lib/features/laboratorio/data/repositories/laudo_repository_impl.dart`: 85%
- `lib/features/laboratorio/presentation/providers/laudo_provider.dart`: 50%
- `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart`: 70%
- `lib/domain/usecases/recomendacao_engine.dart`: 70%
- `lib/features/historico/presentation/historico_page.dart`: 80%
- Agregado critico minimo: 70%

## Variaveis de ambiente (override)

Todos os thresholds podem ser sobrescritos no CI:

- `QUALITY_MIN_CRITICAL_COVERAGE`
- `QUALITY_MIN_GLOBAL_COVERAGE` (opcional)
- `QUALITY_MIN_MAIN_COVERAGE`
- `QUALITY_MIN_ROUTER_COVERAGE`
- `QUALITY_MIN_AUTH_CONTROLLER_COVERAGE`
- `QUALITY_MIN_AUTH_DATASOURCE_COVERAGE`
- `QUALITY_MIN_LAUDO_REPOSITORY_COVERAGE`
- `QUALITY_MIN_LAUDO_PROVIDER_COVERAGE`
- `QUALITY_MIN_RECOMENDACAO_SCREEN_COVERAGE`
- `QUALITY_MIN_RECOMENDACAO_ENGINE_COVERAGE`
- `QUALITY_MIN_HISTORICO_PAGE_COVERAGE`

Opcional:

- `QUALITY_RUN_FULL_TESTS=true` para rodar suite completa alem da suite critica.
