# AGENTIPA — Caderno de Solo

## Objetivo

Este agente orienta o fluxo de release iOS do app `Analise/`, com foco em disciplina de build, rastreabilidade e atualização do histórico de IPA.

## Regras

- Nunca reduza o número de IPA em relação ao último build confirmado.
- Nunca gere IPA com número igual ao último build confirmado.
- Sempre confirmar o build number antes de executar `build_ios.sh`.
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
3. Executar a validação relevante do app.
4. Gerar a IPA.
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
