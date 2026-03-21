# 09 — Erros, riscos e conflitos conhecidos

> **Status:** 🔄 itens identificados e em monitoramento para evitar regressões.
> **Atualizado em:** 2026-03-18

## 1. Documentação duplicada / divergente

- Existem arquivos antigos na raiz e arquivos novos em `docs/`. O risco é manter versões desalinhadas.
- `09_ordem_execucao_prompts.md` e `10_ROADMAP.md` devem ser sincronizados a cada mudança de fase.

## 2. Código duplicado / incompleto

- `AnaliseLocalDatasource` e `*FirestoreDatasource` coexistem. Falta definição explícita do provider ativo por ambiente.
- Captura de localização em `NovaAnaliseScreen` ainda precisa migrar de mock para serviço real com permissão.

## 3. Requisitos e inconsistências

- Bottom Navigation: **RESOLVIDO** no código com 4 abas (Análise, Lab, Histórico, Config).
- `Culturas` agora está fora da bottom nav e acessível por rota dedicada (`/culturas`) e atalhos do Lab.
- `firebase_options.dart`: iOS já com dados reais; Android/web/macos exigem `flutterfire configure` antes de build oficial.
- `firestore.rules` ainda não versionado no repositório.

## 4. Riscos futuros / melhorias rápidas

- Validar inclusão dos markdowns de referência em assets de release.
- Manter App Mapa sincronizado com mudanças de schema da coleção `analises`.
- Implementar troca formal mock/Firestore por configuração de ambiente.

## 5. Riscos introduzidos pela v2 de análise

- Quebra de contrato no UseCase (fósforo): **RESOLVIDO**.
  - `CalcularRecomendacaoUseCase` já consome `FosforoData`.
  - `FosforoFormula.recomendacao` usa `FosforoData.valorParaCalculo`.
- Ambiguidade do K duplicado no laudo Exata: pendente definir regra oficial de entrada.
- Granulometria g/kg no gesso: validar integração fim a fim para garantir uso de argila em `%` no motor.
- Compatibilidade Firestore v1 vs v2: precisa estratégia de migração/versionamento antes de ativar fluxo real.
- Widgets que assumem `double` em campos que viraram objetos (ex.: padrões estilo `ValorDuplo`) devem ser auditados antes da integração completa.

## 6. Ações de mitigação imediata

1. Criar ADR curto com decisão de fonte oficial de documentação (`docs/`).
2. Criar plano de migração de schema Firestore (v1 -> v2) com fallback de leitura.
3. Versionar `firestore.rules` com validação de ownership (`request.auth.uid`).
4. Formalizar estratégia de data source por ambiente (mock vs Firestore).
