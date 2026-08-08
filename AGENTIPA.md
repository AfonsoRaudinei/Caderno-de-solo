# AGENTIPA — Caderno de Solo

## Objetivo

Este agente orienta o fluxo de release iOS do app `Analise/`, com foco em disciplina de build, rastreabilidade e atualização do histórico de IPA.

## Regras

- Nunca reduza o número de IPA em relação ao último build confirmado.
- Nunca gere IPA com número igual ao último build confirmado.
- Sempre confirmar o build number antes de executar `build_ios.sh`.
- Antes de gerar IPA, o `release_gate` / `product_modules_guard` deve confirmar que o módulo
  **Clientes** (e demais features core) ainda existe no working tree.
- Use sempre `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`
  para não saltar o build number na exportação.
- Após cada IPA concluída com sucesso, atualizar este arquivo com:
  - data do build;
  - build number gerado;
  - caminho do IPA;
  - eventuais observações de validação.
- Manter segredo e credencial fora do repositório.
- Não embutir chaves de banco de dados, tokens, senhas ou credenciais em arquivos versionados.
- Usar variáveis de ambiente, Keychain, Firebase/serviços gerenciados ou outro cofre aprovado pelo projeto para segredos.
- Se houver conflito entre este agente e `AGENTS.md`, vale a regra mais restritiva de segurança e arquitetura.

## Procedimento mínimo

1. Ler o estado atual do `Analise/pubspec.yaml`.
2. Confirmar o próximo build number.
3. Executar `./tool/product_modules_guard.sh` e a validação relevante do app.
4. Gerar a IPA via `./build_ios.sh <N>`.
5. Registrar o resultado neste arquivo.

## Histórico de IPA

- 2026-07-14: IPA 164 concluída com sucesso.
  - Build: `1.0.1+164`
  - IPA: `Analise/build/ios/ipa/*.ipa`
  - Observação: build gerado via `./build_ios.sh 164`

- 2026-07-14: IPA 165 concluída com sucesso.
  - Build: `1.0.1+165`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 165` com `release_gate` aprovado

- 2026-07-14: IPA 166 concluída com sucesso.
  - Build: `1.0.1+166`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 166`; `release_gate` reportou violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a exportação da IPA concluiu com sucesso

- 2026-07-15: IPA 167 concluída com sucesso.
  - Build: `1.0.1+167`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 167`; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-15: IPA 168 concluída com sucesso.
  - Build: `1.0.1+168`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 168`; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-20: IPA 169 concluída com sucesso.
  - Build: `1.0.1+169`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 169`; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-21: IPA 170 concluída com sucesso.
  - Build: `1.0.1+170`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 170`; upload de PDFs validado para Exata Brasil, IBRA, Sellar, Solum e MB em testes direcionados; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-21: IPA 171 concluída com sucesso.
  - Build: `1.0.1+171`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 171`; correção defensiva de sessão/permissão em Clientes validada com analyzer e testes direcionados; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-23: IPA 172 concluída com sucesso.
  - Build: `1.0.1+172`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 172`; edição de nutrientes direto na tela de detalhe validada com teste direcionado e analyzer da feature; `Info.plist` embutido confirmou `CFBundleVersion=172`, `CFBundleShortVersionString=1.0.1` e bundle `com.soloforte.soloforte`; `release_gate` voltou a reportar violações de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` e `lib/features/clientes/presentation/talhao_form_screen.dart`, mas a IPA foi concluída com sucesso

- 2026-07-24: IPA 173 concluída com sucesso.
  - Build: `1.0.1+173`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 173`; hardening do upload de laboratórios validado com regressões direcionadas para Exata Brasil, IBRA, Sellar, MB, Solum e fixtures estáveis do texto nativo; `Info.plist` embutido confirmou `CFBundleVersion=173`, `CFBundleShortVersionString=1.0.1` e bundle `com.soloforte.soloforte`; `release_gate` reportou a violação arquitetural pré-existente em `lib/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart`, mas a exportação da IPA concluiu com sucesso

- 2026-07-24: IPA 174 concluída com sucesso.
  - Build: `1.0.1+174`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 174`; telemetria remota passou a exigir autorização explícita de build (`ALLOW_REMOTE_ANALISE_TELEMETRY`) e ficou coberta por regressões de configuração/provider; `Info.plist` embutido confirmou `CFBundleVersion=174`, `CFBundleShortVersionString=1.0.1` e bundle `com.soloforte.soloforte`; `release_gate` reportou a violação arquitetural pré-existente em `lib/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart`, mas a exportação da IPA concluiu com sucesso

- 2026-07-24: IPA 175 concluída com sucesso.
  - Build: `1.0.1+175`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 175`; correção do salvamento de cliente/produtor (token sem query global incompatível com rules, telefone/e-mail opcionais, UX de erro sem pop em falha) validada com analyzer e testes direcionados do módulo Clientes; `Info.plist` embutido confirmou `CFBundleVersion=175`, `CFBundleShortVersionString=1.0.1` e bundle `com.soloforte.soloforte`; `release_gate` reportou a violação arquitetural pré-existente em `lib/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart`, mas a exportação da IPA concluiu com sucesso

- 2026-08-06: IPA 176 concluída com sucesso.
  - Build: `1.0.1+176`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 176`; correção mínima em `AbsorcaoNutrientesCores` restaurou os helpers visuais esperados pela tela de referências e o analyzer direcionado de `lib/features/laboratorio/presentation/referencias` ficou limpo; o fluxo de exportação iOS passou a usar `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false` para impedir salto automático do IPA para `177`; `Info.plist` embutido confirmou `CFBundleVersion=176`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; `release_gate` ainda reporta a violação arquitetural pré-existente em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart`

- 2026-08-06: IPA 177 concluída com sucesso.
  - Build: `1.0.1+177`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 177`; `Info.plist` embutido confirmou `CFBundleVersion=177`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; o fluxo de exportação continua usando `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false` para impedir incremento automático durante a exportação; `release_gate` ainda reporta a violação arquitetural pré-existente em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart`

- 2026-08-06: IPA 178 concluída com sucesso.
  - Build: `1.0.1+178`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 178`; inclui commits `feat(fosforo)` (motor P₂O₅ + módulo Cálculos base) e `feat(potassio)` (motor K₂O completo com calibração); Etapas 2–4 (AppIconBadge, migração palette, rota Cálculos, E2E calibração→recomendação); regressão obrigatória K: `130,2 × 15% = 149,73 kg K₂O/ha`; `Info.plist` embutido confirmou `CFBundleVersion=178`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; exportação via `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`; `release_gate` ainda reporta a violação arquitetural pré-existente em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart`

- 2026-08-06: IPA 179 concluída com sucesso.
  - Build: `1.0.1+179`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa`
  - Observação: build gerado via `./build_ios.sh 179` na branch `cursor/unificar-clientes-analises-9607` (restauração do módulo Clientes + hierarquia Cliente→Fazenda→Talhão); `build_ios.sh` passou a usar `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`; `Info.plist` embutido confirmou `CFBundleVersion=179`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; `release_gate` passou completo nesta branch

- 2026-08-06: IPA 180 concluída com sucesso.
  - Build: `1.0.1+180`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa` (73,9 MB)
  - Observação: build gerado via `./build_ios.sh 180` na branch `cursor/unificar-clientes-analises-9607` (commit `e05eaf1` — motor auditável de K₂O, card de calibração de potássio e refactor de micronutrientes); `product_modules_guard` aprovado; `release_gate` reportou violação pré-existente de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart`, mas a exportação concluiu; `Info.plist` embutido confirmou `CFBundleVersion=180`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; exportação via `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`

- 2026-08-06: IPA 181 concluída com sucesso.
  - Build: `1.0.1+181`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa` (73,9 MB)
  - Observação: build gerado via `./build_ios.sh 181` na branch `cursor/unificar-clientes-analises-9607` (restauração do wiring Recomendação→Cálculos, `calcular_potassio_calculos_usecase` e seção de potássio no módulo Cálculos); `product_modules_guard` aprovado; `release_gate` reportou violação pré-existente de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` (`config_controller.dart`), mas a exportação concluiu; validação Flutter confirmou `Build Number: 181`, `Version Number: 1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; exportação via `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`

- 2026-08-06: IPA 182 concluída com sucesso.
  - Build: `1.0.1+182`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa` (73,9 MB)
  - Observação: build gerado via `./build_ios.sh 182` na branch `cursor/unificar-clientes-analises-9607` (commit `747e8b6` — fusão nav 4 abas Clientes+Análise e seleção de análises na Recomendação por cliente com profundidade livre e chips inline); `product_modules_guard` aprovado; `Info.plist` embutido confirmou `CFBundleVersion=182`, `CFBundleShortVersionString=1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; exportação via `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`

- 2026-08-08: IPA 184 concluída com sucesso.
  - Build: `1.0.1+184`
  - IPA: `Analise/build/ios/ipa/Caderno de Solo.ipa` (71,2 MB)
  - Observação: build gerado via `./build_ios.sh 184` na branch `cursor/fix-analise-blackmode-colors-a4f6` (contrato Black + Azul Samsung e correções de cores hardcoded); pulou o 183 a pedido; `product_modules_guard` aprovado; Flutter validou `Build Number: 184`, `Version Number: 1.0.1`, bundle `com.soloforte.soloforte` e nome `Caderno de Solo`; `release_gate` reportou violação pré-existente de import cruzado em `lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart` (`config_controller.dart`), mas a exportação concluiu; exportação via `tool/export_options_app_store.plist` com `manageAppVersionAndBuildNumber=false`
