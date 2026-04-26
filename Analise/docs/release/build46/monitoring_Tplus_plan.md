# Plano de Monitoramento: T+2h / T+24h / T+48h (Build 46)

Definicoes:
- `T0`: horario em que o build 46 ficou "Ready to Test" e foi liberado para o grupo interno.
- Meta: completar 48h de observacao e gerar decisao formal Go/No-Go.

## T+2h (smoke test + setup de observabilidade)
- [ ] Instalar o build 46 em device fisico (nao simulador).
- [ ] Login com conta real e com conta demo.
- [ ] Fluxo critico 1: `Login -> Lista -> Nova analise -> Salvar -> Voltar -> Listagem`.
- [ ] Fluxo critico 2: `Nova analise -> Capturar GPS -> Confirmar permissao -> Salvar`.
- [ ] Fluxo critico 3: `Abrir detalhe -> Gerar PDF (se existir) -> Voltar`.
- [ ] Registrar qualquer crash/tela branca/loop.
- [ ] Abrir `Crashlytics` e confirmar que o build esta reportando (quando aplicavel).

Check de sucesso:
- Nenhum crash em fluxo critico durante o smoke test.
- Log preenchido: `templates/testflight_monitoring_log_48h_TEMPLATE.md` (criar copia preenchida).

## T+24h (primeira leitura de tendencia)
- [ ] Revisar Crashlytics: quantidade/tendencia de crashes.
- [ ] Revisar feedbacks do TestFlight (se houver).
- [ ] Executar 1 rodada completa de fluxo com dados reais (sem dados pessoais sensiveis).
- [ ] Validar Firestore rules em producao (teste negativo A nao le B).

Check de sucesso:
- Crash rate aceitavel (sem crash em fluxo critico).
- Firestore rules validadas com evidencias (ver template).

## T+48h (gate de estabilidade + Go/No-Go)
- [ ] Consolidar todos os feedbacks e crashes no Monitoring Log.
- [ ] Confirmar que todos requisitos R-01 a R-10 estao FECHADOS.
- [ ] Preparar ata Go/No-Go e coletar aprovacao (PO, QA, iOS/Flutter Lead).
- [ ] Se GO: submeter para App Review no App Store Connect.
- [ ] Se NO-GO: registrar causa e reiniciar ciclo (novo build).

Check de sucesso:
- Ata formal preenchida e assinada (ver template).
- Evidencia do status "Waiting for Review" (print) se submetido.

