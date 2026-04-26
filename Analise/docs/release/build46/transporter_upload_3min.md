# Guia Objetivo: Upload da IPA no Transporter (3 minutos)

## Pre-requisitos (30s)
- Ter a `IPA` do Build 46 pronta localmente (ex: `Runner.ipa`).
- Ter acesso ao App Store Connect com permissao de upload.
- Ter a autenticacao correta do Apple ID (de preferencia com 2FA ja validado).

## Passo a passo (2 min)
1. Abrir o app **Transporter** no macOS.
2. Fazer login com o Apple ID do App Store Connect.
3. Clicar em **Add App** (ou arrastar) e selecionar/arrastar a `IPA`.
4. Conferir que apareceu 1 item na lista (nome do app + bundle).
5. Clicar em **Deliver**.
6. Aguardar o status final:
   - Sucesso: aparece confirmacao de entrega (delivery successful).
   - Falha: aparece erro (normalmente credencial/permissao/metadata).

## Check de sucesso (obrigatorio)
- No Transporter: status de entrega **sucesso** (sem erro).
- No App Store Connect:
  - `My Apps` -> `Caderno de Solo` -> `TestFlight` -> `Builds`.
  - O build 46 aparece em ate ~5-30 minutos como "Processing" e depois "Ready to Test" (pode variar).

## Se falhar (diagnostico rapido)
- Erro de permissao: confirmar que o usuario tem role que permite upload.
- Erro de assinatura/provisionamento: IPA invalida (regerar via pipeline).
- Erro de metadata: conferir bundle id e configuracoes ASC coerentes com o app.

