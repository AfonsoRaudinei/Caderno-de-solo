# TESTFLIGHT MONITORING CHECKLIST (48h)
## App: Caderno de Solo
## Build alvo: `1.0.1+42`
## IPA local: `build/ios/ipa/Caderno de Solo.ipa`
## Data: 2026-04-10

---

## 1) Publicação no TestFlight
- [ ] Upload da IPA concluído no App Store Connect
- [ ] Build processado pela Apple (status: Ready to Test)
- [ ] Notas para testadores preenchidas
- [ ] Grupo interno de teste habilitado

---

## 2) Smoke Test inicial (T+0h a T+2h)
- [ ] Instalação via TestFlight sem erro
- [ ] Login funcionando
- [ ] Cadastro funcionando
- [ ] Lista de análises carregando dados reais
- [ ] Nova análise salva com sucesso
- [ ] Captura de GPS funcionando
- [ ] Histórico/recomendação abrindo sem crash

Registrar evidências:
- Device:
- iOS:
- Resultado:

---

## 3) Observabilidade (T+24h)
- [ ] Crash-free sessions aceitável (sem crash crítico)
- [ ] Sem erro de autenticação em massa
- [ ] Sem erro recorrente de Firestore permission denied
- [ ] Sem regressão crítica de performance

Registrar:
- Crash reports relevantes:
- Erros recorrentes:
- Ação tomada:

---

## 4) Observabilidade (T+48h)
- [ ] Nenhum bloqueador aberto
- [ ] Fluxo principal validado por mais de 1 testador
- [ ] Critérios de release atendidos

Decisão:
- [ ] GO para submit App Review
- [ ] NO-GO (listar motivo)

Motivo/observações:

---

## 5) Critérios de GO para submit
- [ ] Sem crash crítico em 48h
- [ ] Sem falha crítica em login/salvar/GPS
- [ ] Política de Privacidade e URL de suporte já cadastradas
- [ ] App Privacy Nutrition Label preenchido
- [ ] Screenshots obrigatórias de App Store anexadas

