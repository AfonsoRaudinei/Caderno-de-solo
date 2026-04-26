# CADERNO DE SOLO
## PRD — Publicação App Store | Build 46
**Versão:** 2.0 | **Data:** 13 de Abril de 2026 | **Classificação:** Interno

---

## Ficha Técnica

| Campo | Valor |
|---|---|
| **Produto** | Caderno de Solo — App Agronômico de Análise de Solo |
| **Build** | 46 (Codemagic CI/CD — `flutter build ipa --release`) |
| **Versão App** | 1.0.1+46 |
| **Plataforma** | iOS — App Store (distribuição pública, mercado Brasil) |
| **Stack** | Flutter 3.16+ · Dart 3.0+ · Riverpod 2.5 · Firebase Auth + Firestore · Hive · Codemagic |
| **Mercado** | Brasil — Agronomia e manejo de solo (PT-BR exclusivo) |
| **Status ASC** | Build 46 presente no App Store Connect — aguarda submit |

---

## 1. Objetivo e Contexto Estratégico

O Caderno de Solo é um aplicativo iOS especializado em análise agronômica de solo para o mercado agrícola brasileiro. Calcula recomendações de calcário, gesso, fósforo, potássio e micronutrientes com base em referências científicas consolidadas (ESALQ/Fancelli, EMBRAPA, UEPG/Caires).

Este PRD define os requisitos, critérios de aceite, trilhas de execução e gates de aprovação para publicar o Build 46 na App Store com **conformidade integral e zero rejeição bloqueadora**.

### 1.1 Resultados Esperados

- Build 46 aprovado no App Review sem rejeição bloqueadora em primeira tentativa
- TestFlight estável em device físico por mínimo **48 horas contínuas**
- Checklist de conformidade 100% concluído com evidências auditáveis
- Conta de demonstração funcional para o reviewer Apple
- Screenshots validadas para todos os slots obrigatórios do App Store Connect
- Firestore rules de produção aplicadas — zero acesso público indevido

### 1.2 Escopo

- Conformidade de conta Apple Developer e App Store Connect
- Conformidade técnica do binário iOS (Build 46)
- Privacidade, dados e SDKs de terceiros (Firebase Analytics, Crashlytics, Auth, Firestore)
- Metadados, assets e screenshots da loja
- TestFlight, monitoramento 48h e gate Go/No-Go
- Dossiê de evidências para auditoria interna

### 1.3 Fora de Escopo

- Refatorações de código não relacionadas à publicação
- Novas features que alterem o escopo funcional aprovado
- Internacionalização (i18n) — app é exclusivamente PT-BR por decisão de produto

---

## 2. Diagnóstico Pré-Submit — Estado Atual

> Verificação técnica realizada diretamente no repositório antes desta versão do PRD.

| Item Verificado | Status | Observação Técnica |
|---|---|---|
| `ITSAppUsesNonExemptEncryption` no Info.plist | OK | Chave presente como `<false/>`. Upload não bloqueado por compliance de criptografia. |
| Conta de demonstração Firebase | ABERTO | Campo "Demo account" no `app_store_connect_pack.md` está como "preencher". **Blocker crítico.** |
| Screenshots iPhone 6.9" (1320×2868) | VALIDAR | 7 PNGs em `screenshots_test/iphone_69`. Dimensões corretas. Visual **não revisado**. |
| Screenshots iPhone 6.5" (1242×2688) | VALIDAR | 7 PNGs em `screenshots_test/iphone_65`. Dimensões corretas. Visual **não revisado**. |
| Pasta `screenshots/` definitiva | VAZIA | Assets finais não promovidos. Nenhuma imagem na pasta definitiva. |
| Build 46 no App Store Connect | PRESENTE | Build confirmado no ASC. Aguarda preenchimento de metadados e submit. |
| Firestore Rules de produção | VERIFICAR | Regras não versionadas no repo. Validar no Firebase Console antes do Go/No-Go. |
| GPS / Geolocator em produção | VERIFICAR | Histórico indica coordenadas fixas (São Paulo) em `NovaAnaliseScreen`. Confirmar correção. |

### Blocker Crítico — Conta Demo

A Apple exige conta de demonstração para qualquer app com login. Sem ela, o reviewer não acessa as funcionalidades e a rejeição é imediata.

**Ação:** Criar `demo@cadernosolo.com.br` no Firebase Console (sem código), logar no app com Build 46, salvar 2 análises completas com dados fictícios, documentar credenciais no `app_store_connect_pack.md`.

### Ação Necessária — Screenshots

As 14 imagens precisam de revisão visual antes do upload. Critérios: sem elementos de debug, sem dados pessoais reais, sem textos "teste", sem UI de beta/dev. Se aprovadas: mover de `screenshots_test/` para `screenshots/` e subir no ASC.

---

## 3. Requisitos Mandatórios Apple — Critérios de Aceite

> Um único requisito ABERTO no momento do submit é suficiente para rejeição. O gate Go/No-Go só abre quando **todos** estiverem FECHADOS.

### R-01 | App Completo e Funcional (Risco Alto)

| Campo | Detalhe |
|---|---|
| **Critério** | Nenhum mock visível ao usuário no fluxo principal. Sem crash no fluxo crítico: login → nova análise → salvar → histórico → PDF. GPS funcional com permissão real (não coordenadas fixas). |
| **Aceite** | Smoke test em device físico com Build 46 + TestFlight validado por 48h. Todos os fluxos críticos executados e documentados. |
| **Dono** | iOS/Flutter Lead + QA |

### R-02 | Metadados Precisos e Completos (Risco Médio)

| Campo | Detalhe |
|---|---|
| **Critério** | Nome, subtítulo, descrição, keywords, What's New e notas de review refletem o app real. Sem promessas de funcionalidades não implementadas. |
| **Aceite** | Revisão cruzada PO + Release Manager. Todos os campos preenchidos no ASC sem pendência. |
| **Dono** | Release Manager + PO |

### R-03 | Privacidade — App Privacy Label (Risco Alto)

| Campo | Detalhe |
|---|---|
| **Critério** | Dados coletados declarados por SDK: Firebase Analytics, Crashlytics, Auth, Firestore. Finalidade informada por categoria (Analytics, App Functionality). |
| **Aceite** | Privacy Matrix vFinal aprovada. Formulário App Privacy no ASC sem inconsistência entre label e coleta real. |
| **Dono** | Product + Engenharia |

### R-04 | URLs Obrigatórias Válidas (Risco Baixo)

| Campo | Detalhe |
|---|---|
| **Critério** | URL de Suporte e Política de Privacidade acessíveis (HTTP 200). Testadas em Safari privado e em rede mobile. |
| **Aceite** | Teste manual em Safari privado. Registro de data/hora no checklist. |
| **Dono** | Release Manager |

### R-05 | Permissões Mínimas e Justificadas (Risco Médio)

| Campo | Detalhe |
|---|---|
| **Critério** | Somente chaves necessárias no `Info.plist` com purpose strings em PT-BR, claras e coerentes. Camera (`NSCameraUsageDescription`) apenas se o Build realmente abrir a camera. |
| **Aceite** | Auditoria do `Info.plist` + teste funcional de cada permissão em device físico. Sem chaves órfãs. |
| **Dono** | iOS/Flutter Lead |

### R-06 | Export Compliance — Criptografia (Risco Baixo)

| Campo | Detalhe |
|---|---|
| **Critério** | `ITSAppUsesNonExemptEncryption = false` presente no `Info.plist`. |
| **Aceite** | Já verificado no repositório. |
| **Dono** | iOS/Flutter Lead |

### R-07 | Screenshots e Assets (Risco Médio)

| Campo | Detalhe |
|---|---|
| **Critério** | Slots iPhone 6.9" (1320×2868) e iPhone 6.5" (1242×2688) preenchidos no ASC. Sem debug, dados pessoais, marcas d'água ou textos de beta. |
| **Aceite** | Upload sem erro de dimensão. Revisão visual por 2 pessoas antes do upload. Pasta `screenshots/` preenchida. |
| **Dono** | Design + Release Manager |

### R-08 | Conta de Demonstração (Risco Alto)

| Campo | Detalhe |
|---|---|
| **Critério** | Conta demo criada no Firebase Auth, funcional sem convite. Pelo menos 2 análises completas salvas para o reviewer navegar. |
| **Aceite** | Criar `demo@cadernosolo.com.br`, testar login em device com Build 46 e documentar credenciais. |
| **Dono** | Release Manager |

### R-09 | Qualidade Operacional (Risco Alto)

| Campo | Detalhe |
|---|---|
| **Critério** | Zero blocker em: login, nova análise com GPS real, salvar, gerar PDF, histórico. Sem crash, tela branca ou loop infinito. |
| **Aceite** | Checklist de regressão completo em device físico com Build 46. Assinado por QA Lead. |
| **Dono** | QA Lead |

### R-10 | Segurança — Firestore Rules (Risco Alto)

| Campo | Detalhe |
|---|---|
| **Critério** | Regras aplicadas em produção: usuário autenticado acessa apenas seus documentos. Sem permissão pública. |
| **Aceite** | Acesso válido + teste negativo (usuário A não lê B) com evidência. |
| **Dono** | Engenharia |

---

## 4. Plano de Execução — Trilhas A a F

Trilhas operacionais estão documentadas e operacionalizadas em:
- `README.md`
- `transporter_upload_3min.md`
- `testflight_post_upload_checklist.md`
- `monitoring_Tplus_plan.md`
- `templates/*`

---

## 10. Referências Oficiais Apple

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- TestFlight Overview: https://developer.apple.com/testflight/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- Export Compliance: https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations
- Screenshot Specifications: https://help.apple.com/app-store-connect/#/devd274dd925
