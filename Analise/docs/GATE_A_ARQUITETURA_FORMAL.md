# Gate A - Diagnostico Arquitetural Formal

Status: `ATIVO`  
Versao: `1.0`  
Ultima atualizacao: `2026-04-05`

## 1. Objetivo
Formalizar a arquitetura alvo do app e definir criterios objetivos para aprovar o Gate A antes da sequencia dos gates de execucao, fronteiras, testes, CI/CD e observabilidade.

## 2. Escopo Arquitetural
Este gate cobre:

1. Estrutura arquitetural oficial do repositorio.
2. Fronteiras de dependencia entre camadas e features.
3. Criterios de aceite auditaveis por comando.
4. Evidencias minimas para declarar o sistema "Apto no Gate A".

## 3. Mapa Arquitetural Oficial

### 3.1 Camadas base

- `lib/core`: infraestrutura compartilhada (router, tema, servicos, utilitarios).
- `lib/features`: modulos de produto, preferencialmente organizados em `application`, `data`, `domain`, `presentation`.
- `lib/domain`: motores/formulas/entidades globais de negocio reutilizaveis.
- `lib/data`: datasources e adaptadores de dados globais.
- `lib/main.dart`: bootstrap, inicializacao e composicao da aplicacao.

### 3.2 Features atuais

- `analise`
- `auth`
- `config`
- `culturas`
- `historico`
- `laboratorio`
- `main`

### 3.3 Fluxos criticos de negocio

- `main`
- `router`
- `auth`
- `laudo`
- `recomendacao`
- `historico`

## 4. Contrato de Fronteiras

### 4.1 Regras obrigatorias

1. `domain` nao pode importar `presentation` (nem de mesma feature, nem de outra feature).
2. `domain` nao pode importar `application` de feature.
3. `presentation` de uma feature nao pode importar `presentation` de outra feature.
4. `router` centralizado em `lib/core/router/app_router.dart`.
5. Servicos cross-cutting (ex: observabilidade) devem residir em `lib/core/services`.

### 4.2 Matriz de dependencia permitida (direcao)

- `presentation -> application|domain|core`
- `application -> domain|data|core`
- `data -> domain|core`
- `domain -> core (contratos puros)`  

Observacao: import de `domain -> features/*/presentation` e `cross-feature presentation` e proibido.

## 5. Criterios de Aceite do Gate A

O Gate A e aprovado quando TODOS os itens abaixo estiverem `OK`:

1. Documento arquitetural formal existe e esta versionado no repositorio.  
2. Mapa de camadas/features/fluxos criticos esta explicito.  
3. Regras de fronteira estao explicitas com matriz de dependencia.  
4. Verificacao automatica de fronteiras nao detecta violacoes criticas.  
5. `flutter analyze` sem erros.  
6. Suite critica dos fluxos `main/router/auth/laudo/recomendacao/historico` passando.  
7. CI possui etapas de `pub get`, `analyze`, `test`, `build` documentadas.  
8. Evidencias de aprovacao registradas na secao "Resultado da Auditoria Gate A".

## 6. Protocolo de Auditoria (comandos)

### 6.1 Fronteiras domain -> presentation/application

```bash
rg -n "import 'package:soloforte/features/.*/presentation|import 'package:soloforte/features/.*/application|import 'package:soloforte/presentation" -S lib/domain lib/features/*/domain
```

Esperado: nenhum resultado.

### 6.2 Cross-feature presentation

```bash
python3 - <<'PY'
from pathlib import Path
import re
root=Path('lib/features')
issues=[]
for f in root.rglob('presentation/**/*.dart'):
    txt=f.read_text(encoding='utf-8',errors='ignore')
    me=f.parts[2] if len(f.parts)>2 else None
    for i,l in enumerate(txt.splitlines(),1):
        m=re.search(r"import 'package:soloforte/features/([^/]+)/presentation/",l)
        if m and m.group(1)!=me:
            issues.append((f,i,l.strip()))
print("OK" if not issues else f"FOUND={len(issues)}")
PY
```

Esperado: `OK`.

### 6.3 Integridade estatica

```bash
flutter analyze
```

Esperado: sem erros.

### 6.4 Fluxos criticos executando

```bash
flutter test --reporter compact \
  test/core/router/app_router_test.dart \
  test/main_test.dart \
  test/presentation/login_controller_test.dart \
  test/data/datasources/remote/auth_datasource_test.dart \
  test/features/laboratorio/data/laudo_repository_impl_test.dart \
  test/features/laboratorio/presentation/recomendacao/recomendacao_screen_test.dart \
  test/features/historico/presentation/historico_page_test.dart \
  test/domain/usecases/recomendacao_engine_test.dart
```

Esperado: `All tests passed`.

## 7. Resultado da Auditoria Gate A

Rodada de auditoria:

- Data: `2026-04-05`
- Auditor: `Codex (Auditoria Flutter/Dart)`
- Commit/Branch: `f65f208 / main`
- Fronteiras (6.1): `OK` (sem violacoes detectadas)
- Cross-feature presentation (6.2): `OK` (sem violacoes detectadas)
- Analyze (6.3): `OK` (`flutter analyze` sem erros)
- Suite critica (6.4): `OK` (`All tests passed`)
- Decisao Gate A: `APROVADO`
- Pendencias para aprovacao: `Nenhuma nesta rodada`

## 8. Politica de Mudanca

Qualquer alteracao estrutural em camadas, roteamento central, fronteiras entre features ou estrategia de composicao deve atualizar este documento antes do merge.
