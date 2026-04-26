# Checklist Exato: TestFlight apos o Upload (Build 46)

Objetivo: garantir que o build esta pronto para distribuicao e que o monitoramento de 48h pode comecar sem risco de rejeicao por falta de acesso/fluxo.

## 1) Build processing
- [ ] O build 46 saiu de "Processing" e esta "Ready to Test".
- [ ] A aba `Build Metadata` (quando existir) nao mostra pendencias bloqueadoras.

## 2) Compliance / Export (se solicitado pelo ASC)
- [ ] Se o App Store Connect perguntar sobre criptografia/export: responder consistente com `ITSAppUsesNonExemptEncryption=false` do app.

## 3) Test Details (o que precisa estar preenchido para testar)
- [ ] `What to Test` preenchido (curto e objetivo).
- [ ] `Beta App Description` preenchido (se exigido na sua tela).
- [ ] `Beta Feedback Email` configurado (email que recebe feedback).

## 4) Distribuicao (Internal Testing)
- [ ] Grupo interno existe e esta ativo.
- [ ] Build 46 adicionado ao grupo interno.
- [ ] Pelo menos 3 testadores internos conseguem instalar em devices fisicos diferentes.

## 5) App Review Information (para App Store Review, nao beta)
- [ ] "Sign-in required" = Yes (se app exige login).
- [ ] Conta demo definida (usuario/senha) e testada (ver PRD R-08).
- [ ] Notes for Review explicam o fluxo principal e onde tocar para capturar GPS.

## Check de sucesso (obrigatorio)
- Pelo menos 1 device fisico instalou e abriu o app via TestFlight.
- Smoke test T+2h executado e registrado no log (ver `monitoring_Tplus_plan.md`).

