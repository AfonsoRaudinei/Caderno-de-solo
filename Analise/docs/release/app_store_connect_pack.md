# APP STORE CONNECT PACK
## App: Caderno de Solo
## Versão do pacote: 2026-04-10

Este arquivo centraliza textos e decisões para preencher o App Store Connect sem retrabalho.

---

## 1) APP INFORMATION

### Campos sugeridos
- Nome do app: `Caderno de Solo`
- Subtítulo: `Análise e recomendação de solo`
- Categoria primária: `Productivity`
- Categoria secundária: `Reference`
- Classificação etária: `4+`
- Copyright: `© 2026 Caderno de Solo`

### URLs
- URL de Suporte: `https://afonsoraudinei.github.io/SoloForte-Termos-de-Uso/`
- URL de Política de Privacidade: `https://afonsoraudinei.github.io/SoloForte-Pol-tica-de-Privacidade/`
- URL de Marketing (opcional): `https://afonsoraudinei.github.io/SoloForte-Termos-de-Uso/`

---

## 2) PROMOTIONAL TEXT (opcional)

Use no campo “Promotional Text”:

`Organize laudos de solo, capture localização em campo e gere recomendações agronômicas com mais consistência no dia a dia.`

---

## 3) DESCRIÇÃO (copiar/colar)

`O Caderno de Solo é um aplicativo para organização de análises de solo e apoio à recomendação agronômica em rotina de campo.

Com ele, você cadastra e gerencia amostras por talhão, registra informações técnicas do laudo, captura localização por GPS e mantém histórico estruturado para consulta.

Principais recursos:
- Cadastro e edição de análises de solo por talhão
- Importação e organização de dados de laudos
- Captura de latitude/longitude no ponto de coleta
- Cálculos e derivados técnicos para apoio à interpretação
- Histórico de análises e recomendações
- Sincronização segura com autenticação de usuário

O app foi desenvolvido para tornar o fluxo técnico mais ágil, reduzir retrabalho no preenchimento e facilitar rastreabilidade das informações agronômicas.

Observação: as recomendações devem sempre ser validadas por profissional habilitado, considerando contexto local, histórico da área e objetivo de manejo.`

---

## 4) KEYWORDS (<= 100 caracteres)

Use exatamente esta linha:

`analisesolo,calagem,adubacao,agronomia,fertilidade,laudo,recomendacao,gps`

---

## 5) WHAT'S NEW (versão atual)

Título interno sugerido: `Novidades da versão 1.0.1`

Texto:

`- Fluxo principal com dados reais no Firestore
- Captura de GPS real na Nova Análise
- Ajustes de estabilidade e confiabilidade no salvamento
- Melhorias de usabilidade e correções gerais`

---

## 6) APP REVIEW INFORMATION

### Contact Information
- First Name: `Afonso`
- Last Name: `Raudinei`
- Phone Number: `preencher`
- Email Address: `preencher`

### Sign-in required?
- `Yes` (app usa autenticação)

### Demo account (se solicitado no review)
- Username: `preencher`
- Password: `preencher`

### Notes for Review (copiar/colar)
`O app exige autenticação para acesso aos dados de análise.
Principais fluxos para validação:
1) Login/Cadastro
2) Nova Análise (incluindo captura de GPS)
3) Salvamento e listagem de análises
4) Histórico de recomendações

A captura de localização é opcional e ocorre apenas quando o usuário toca no botão de captura de GPS.`

---

## 7) PRIVACY NUTRITION LABEL (App Privacy)

### Tracking
- “Data Used to Track You”: `No`

### Data Collection (declarar como coletado)

1. `Contact Info > Email Address`
- Coletado: `Yes`
- Vinculado ao usuário: `Yes`
- Finalidade: `App Functionality`, `Account Management`

2. `Identifiers > User ID`
- Coletado: `Yes` (UID de autenticação)
- Vinculado ao usuário: `Yes`
- Finalidade: `App Functionality`

3. `Location > Precise Location`
- Coletado: `Yes` (quando usuário usa captura GPS)
- Vinculado ao usuário: `Yes`
- Finalidade: `App Functionality`

4. `User Content > Other User Content`
- Coletado: `Yes` (dados de análises/laudos preenchidos no app)
- Vinculado ao usuário: `Yes`
- Finalidade: `App Functionality`

5. `Diagnostics > Crash Data`
- Coletado: `Yes` (Crashlytics em release)
- Vinculado ao usuário: `No` (declarar “Not Linked to User” se essa for sua seleção no formulário)
- Finalidade: `App Functionality`, `Analytics`

6. `Diagnostics > Performance Data`
- Coletado: `Yes` (telemetria de performance/estabilidade)
- Vinculado ao usuário: `No` (declarar “Not Linked to User” se essa for sua seleção no formulário)
- Finalidade: `Analytics`

### Dados não coletados (marcar como não coletado)
- Health & Fitness
- Financial Info
- Purchases
- Sensitive Info
- Contacts
- Browsing History

---

## 8) SCREENSHOTS (check operacional)

Obrigatório preparar no App Store Connect:
- iPhone 6.9" (1320 x 2868)
- iPhone 6.5" (1242 x 2688)

Sugestão de sequência de telas:
1. Login
2. Lista de análises
3. Nova análise (grade)
4. Captura de GPS
5. Detalhe da análise
6. Histórico/recomendação

---

## 9) PRE-SUBMIT GO/NO-GO

Marcar tudo antes de enviar:
- [ ] Política de Privacidade pública cadastrada
- [ ] URL de suporte cadastrada
- [ ] App Privacy preenchido
- [ ] Build TestFlight validado em device físico
- [ ] Sem crash crítico por 48h
- [ ] Screenshots obrigatórias enviadas
- [ ] What’s New preenchido
- [ ] Categoria + classificação etária definidas

---

## 10) LINKS OFICIAIS EM USO

- Termos de Uso: `https://afonsoraudinei.github.io/SoloForte-Termos-de-Uso/`
- Política de Privacidade: `https://afonsoraudinei.github.io/SoloForte-Pol-tica-de-Privacidade/`
