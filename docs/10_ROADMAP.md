# 10 — Roadmap dos 14 prompts faseados

> **Status geral:** 🔄 maioria das fases concluída; itens ativos concentrados em integração Firebase (11) e validação operacional de localização (12).
> **Atualizado em:** 2026-03-18

| Prompt | Título | Status | Observações / próximo passo |
| --- | --- | --- | --- |
| 1 | Estrutura do Projeto | ✅ | Pasta `Analise/` com Clean Architecture e `pubspec` configurado. |
| 2 | Design System iOS | ✅ | `AppColors`, `AppTextStyles`, `AppTheme` e tokens em `core/theme`. |
| 3 | Widgets base | ✅ | `AppButton`, `AppCard`, `AppInput`, `AppDropdown`, `NutrienteCard`, `NumFieldWidget`. |
| 4 | Tela de Login | ✅ | Login funcional com validações e redirecionamento via `GoRouter`. |
| 5 | Cadastro em 3 etapas | ✅ | `CadastroPage` com `PageView`, validações e `CadastroController` com Firebase Auth. |
| 6 | Recuperar senha | ✅ | `RecuperarSenhaPage` com feedback visual e controller dedicado. |
| 7 | Navegação principal (Bottom Nav 4 tabs) | ✅ | `MainPage` com 4 abas (`Análise`, `Lab`, `Histórico`, `Config`). `Culturas` removida da nav principal. |
| 8 | Lab (Calibração + Recomendação) | ✅ | `LabPage` com `TabBar` de 2 tabs (`Calibração` e `Recomendação`), providers conectados. |
| 9 | Análise de Solo | 🔄 | `AnaliseFormPage` ainda aponta para `NovaAnaliseScreen` (alias). Migração de fósforo no use case foi concluída (`FosforoData.valorParaCalculo`); falta consolidar fluxo v2 no formulário e persistência final. |
| 10 | Histórico + Configurações | ✅ | `HistoricoPage`, `ConfigPage`, `BaseDados*` e `FeedbackPage` implementados. |
| 11 | Firebase Auth + Firestore | 🔄 | Auth pronto e datasource com comutação (`AppConfig.useFirestore` + provider), mas falta validação E2E com dados reais e regras versionadas. |
| 12 | Localização GPS | 🔄 | `LocationService` com `geolocator/geocoding` já implementado e integrado ao fluxo; pendente validação final em dispositivo e configuração de chave/ambiente Android. |
| 13 | Testes e qualidade | ✅ | Fórmulas e login cobertos; ampliar para fluxo de formulário v2 e integração de dados. |
| 14 | Build e TestFlight | ✅ | `codemagic.yaml`, `build_ios.sh` e checklist em `07_BUILD_DISTRIBUTION.md`. |

## Notas extras

- Próximo passo da fase 11: validar Firestore real no fluxo principal (`analiseDataSourceProvider`) com dados e regras de segurança.
- Para a fase 12: validar captura em device real (permissão negada, timeout, precisão baixa, endereço indisponível).
- Manter sincronia com `09_ordem_execucao_prompts.md` a cada atualização de status.

## Pendências críticas pré-integração completa

1. Conectar o fluxo final do formulário novo (`/analise/nova`) ao modelo v2 completo e persistência no caminho principal.
2. Definir estratégia de migração de schema Firestore (v1 campos planos vs v2 objetos aninhados).
3. Confirmar contrato de entrada para K duplicado (Exata) e regra oficial de normalização.
4. Versionar e publicar `firestore.rules` no repositório.
