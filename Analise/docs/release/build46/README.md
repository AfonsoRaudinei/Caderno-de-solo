# Build 46 Release Ops (App Store)

Este diretório guarda artefatos operacionais (sem alterar o app) para publicar o Build 46 no App Store Connect/TestFlight com evidencias auditaveis.

URLs oficiais (App Store Connect):
- Termos de Uso: https://afonsoraudinei.github.io/SoloForte-Termos-de-Uso/
- Política de Privacidade: https://afonsoraudinei.github.io/SoloForte-Pol-tica-de-Privacidade/

Campos ASC (mapeamento recomendado):
- `Privacy Policy URL` -> Política de Privacidade
- `Support URL` -> idealmente uma página de suporte (ou, provisoriamente, uma página que tenha contato claro)

Arquivos principais:
- `transporter_upload_3min.md`: guia objetivo de upload de IPA via Transporter.
- `testflight_post_upload_checklist.md`: checklist exato do que validar/marcar no TestFlight apos o upload.
- `monitoring_Tplus_plan.md`: plano T+2h / T+24h / T+48h e gate Go/No-Go.

Templates (preencher e salvar como evidencia):
- `templates/testflight_monitoring_log_48h_TEMPLATE.md`
- `templates/go_no_go_minutes_TEMPLATE.md`
- `templates/firestore_rules_validation_TEMPLATE.md`
- `templates/build_validation_report_TEMPLATE.md`
