# 📱 Especificação de Telas

> Detalhamento de cada página: objetivo, campos, ações e comportamentos.

---

## 🔐 AUTH — Fora do Bottom Nav

### Login

**Objetivo:** Autenticar o usuário.

| Campo | Tipo | Validação |
|---|---|---|
| E-mail | TextInput | formato e-mail válido |
| Senha | TextInput (oculto) | mínimo 6 caracteres |

**Ações:**
- `Entrar` → autenticar → ir para tab Análise
- `Cadastrar-se` → ir para Cadastro
- `Esqueci a senha` → ir para Recuperar Senha

**Comportamento:**
- Erro de auth: toast vermelho discreto
- Loading: botão com `CircularProgressIndicator`
- Token salvo em `flutter_secure_storage`

---

### Cadastro

**Objetivo:** Criar conta nova.

| Campo | Tipo | Validação |
|---|---|---|
| Nome completo | TextInput | obrigatório |
| E-mail | TextInput | formato válido, único |
| Senha | TextInput (oculto) | mínimo 8 chars |
| Confirmar senha | TextInput (oculto) | igual ao campo senha |
| Perfil | Dropdown | Agrônomo / Produtor / Técnico |
| Empresa/Propriedade | TextInput | opcional |

**Ações:**
- `Cadastrar` → criar conta → ir para Login
- `Já tenho conta` → voltar para Login

---

### Recuperar Senha

**Objetivo:** Enviar e-mail de recuperação.

| Campo | Tipo |
|---|---|
| E-mail | TextInput |

**Ações:**
- `Enviar` → enviar e-mail → exibir confirmação

---

## 🔬 TAB 1 — Análise de Solo

**Objetivo:** Inserir dados da análise laboratorial de solo para gerar recomendação.

### Seção: Identificação

| Campo | Tipo |
|---|---|
| Nome da área/talhão | TextInput |
| Cultura | Dropdown |
| Data da coleta | DatePicker |
| Laboratório | TextInput (opcional) |

### Seção: Localização

| Campo | Tipo | Observação |
|---|---|---|
| Latitude | Double (automático) | Capturado via GPS |
| Longitude | Double (automático) | Capturado via GPS |
| Município | String (automático) | Reverse geocoding |
| Estado | String (automático) | Reverse geocoding |
| Descrição da área | TextInput | Ex: "Talhão 3 - norte" (manual) |

**Ação:** botão `📍 Usar localização atual` → captura instantânea  
**Pin no mapa:** cor varia conforme V% calculado (🟢 🟡 🔴)

---

### Seção: Dados Físicos

| Campo | Tipo | Unidade |
|---|---|---|
| Textura / Argila | Dropdown ou Numérico (7 dígitos) | % |
| Profundidade | Dropdown | 0-20cm / 0-40cm |

### Seção: pH e Tampão

| Campo | Tipo | Unidade |
|---|---|---|
| pH em água | Numérico (7 dígitos) | — |
| pH SMP (tampão) | Numérico (7 dígitos) | — |
| pH CaCl₂ | Numérico (7 dígitos) | — |

### Seção: Macronutrientes

| Campo | Tipo | Unidade |
|---|---|---|
| Fósforo (P) | Numérico (7 dígitos) | mg/dm³ |
| Potássio (K) | Numérico (7 dígitos) | mmolc/dm³ |
| Cálcio (Ca) | Numérico (7 dígitos) | mmolc/dm³ |
| Magnésio (Mg) | Numérico (7 dígitos) | mmolc/dm³ |
| Enxofre (S) | Numérico (7 dígitos) | mg/dm³ |

### Seção: Acidez e CTC

| Campo | Tipo | Unidade |
|---|---|---|
| Alumínio (Al) | Numérico (7 dígitos) | mmolc/dm³ |
| H+Al | Numérico (7 dígitos) | mmolc/dm³ |
| CTC | calculado automaticamente | mmolc/dm³ |
| V% (Saturação de bases) | calculado automaticamente | % |

### Seção: Micronutrientes (expansível)

| Campo | Tipo | Unidade |
|---|---|---|
| Boro (B) | Numérico (7 dígitos) | mg/dm³ |
| Cobre (Cu) | Numérico (7 dígitos) | mg/dm³ |
| Ferro (Fe) | Numérico (7 dígitos) | mg/dm³ |
| Manganês (Mn) | Numérico (7 dígitos) | mg/dm³ |
| Zinco (Zn) | Numérico (7 dígitos) | mg/dm³ |

**Ações:**
- `Calcular` → gerar recomendação → ir automaticamente para tab Lab > Recomendação
- `Salvar Rascunho` → salvar localmente
- `Limpar` → limpar formulário (confirmar com dialog)

---

## ⚗️ TAB 2 — Lab (TabBar interna)

### Tab 2a — Calibração

**Objetivo:** Definir os parâmetros e referências usados nos cálculos de cada nutriente.

> Cards organizados por nutriente. Cada card é expansível (accordion).

---

#### Card: Calcário 🪨

| Campo | Tipo |
|---|---|
| Método de cálculo | Dropdown: IAC / Embrapa / SMP / V% |
| pH alvo | Numérico (7 dígitos) |
| PRNT do calcário (%) | Numérico (7 dígitos) |
| Referência técnica | Dropdown (Base de Dados) |

---

#### Card: Gesso Agrícola 💎

| Campo | Tipo |
|---|---|
| Método | Dropdown: Embrapa / IAC / Percentual argila |
| Teor de Ca no gesso (%) | Numérico (7 dígitos) |
| Referência técnica | Dropdown (Base de Dados) |

> ⚠️ Gesso e Enxofre ficam visualmente próximos — relacionados.

---

#### Card: Fósforo 🔴

| Campo | Tipo |
|---|---|
| Extrator | Dropdown: Mehlich-1 / Resina / Mehlich-3 |
| Classe de solo (argila) | Dropdown: arenoso / médio / argiloso |
| Nível crítico | Numérico (7 dígitos) mg/dm³ |
| Referência técnica | Dropdown (Base de Dados) |

---

#### Card: Enxofre 🟢

| Campo | Tipo |
|---|---|
| Nível crítico (S) | Numérico (7 dígitos) mg/dm³ |
| Fonte recomendada | Dropdown: Gesso / Sulfato de amônio / Outro |
| Referência técnica | Dropdown (Base de Dados) |

> ⚠️ Enxofre exibido logo abaixo de Fósforo e Gesso na UI.

---

#### Card: Potássio ⚡

| Campo | Tipo |
|---|---|
| Nível crítico (K) | Numérico (7 dígitos) mmolc/dm³ |
| % K na CTC alvo | Numérico (7 dígitos) |
| Referência técnica | Dropdown (Base de Dados) |

---

#### Card: Micronutrientes 🔬

Sub-cards para: B, Cu, Fe, Mn, Zn

| Campo | Tipo |
|---|---|
| Nível crítico (por elemento) | Numérico (7 dígitos) |
| Extrator | Dropdown: DTPA / Mehlich-1 |
| Referência técnica | Dropdown (Base de Dados) |

---

**Ações de Calibração:**
- `Salvar Calibração` → salvar como perfil nomeado
- `Perfis salvos` → dropdown para carregar calibração anterior
- CRUD completo: Editar / Excluir / Duplicar perfil

---

### Tab 2b — Recomendação

**Objetivo:** Exibir resultado calculado com referências citadas.

> Atualiza automaticamente ao mudar calibração (Riverpod).

#### Layout (estilo Perplexity)

```
┌─────────────────────────────────────────┐
│ Recomendação para: [Nome da área]        │
│ Cultura: Soja  |  Data: 10/03/2026      │
└─────────────────────────────────────────┘

┌── Calcário ──────────────────────────────┐
│  Necessidade: 2,5 t/ha                  │
│  Método: SMP → pH alvo 6.0              │
│  ¹ ² (referências clicáveis)            │
└─────────────────────────────────────────┘

┌── Gesso ─────────────────────────────────┐
│  Necessidade: 800 kg/ha                 │
│  ¹ (referência clicável)               │
└─────────────────────────────────────────┘
... (um card por nutriente)

┌── Referências ───────────────────────────┐
│  [1] Boletim 100 - IAC, 1997            │
│  [2] Embrapa Cerrados, 2004             │
└─────────────────────────────────────────┘
```

**Ações:**
- `Salvar Recomendação` → vai para Histórico
- `Compartilhar` → PDF ou texto
- Toque na referência → modal com dados completos da fonte

---

## 📋 TAB 3 — Histórico

**Objetivo:** Listar análises e recomendações anteriores.

**Layout:** Lista com cards compactos.

| Item do card | Dado |
|---|---|
| Título | Nome da área |
| Subtítulo | Cultura + Data |
| Badge | Status: Rascunho / Completo |
| Ação rápida | → abrir / → excluir (swipe) |

**Filtros (top da tela):**
- Por data (DateRange)
- Por cultura (Dropdown)
- Por área/talhão (TextSearch)

**CRUD:**
- Abrir → ver análise + recomendação salva
- Editar → reabrir formulário
- Excluir → swipe left (confirmar com dialog)

---

## ⚙️ TAB 4 — Config

### Perfil

| Campo | Tipo |
|---|---|
| Nome | TextInput |
| E-mail | TextInput (leitura) |
| Perfil | Dropdown |
| Empresa | TextInput |
| Alterar senha | → modal |

### Base de Dados

**Objetivo:** Gerenciar referências técnicas usadas na Calibração.

| Campo | Tipo |
|---|---|
| Nome da referência | TextInput |
| Tipo | Dropdown: Boletim / Tese / Artigo / Embrapa / IAC / Outro |
| Autor(es) | TextInput |
| Ano | Numérico (4 dígitos) |
| Fórmula/Método associado | Dropdown: Calcário / Gesso / P / K / S / Micro |
| Descrição | TextArea |
| Link/DOI | TextInput (opcional) |

**CRUD completo:** Adicionar / Editar / Excluir / Visualizar

### Feedback

| Campo | Tipo |
|---|---|
| Tipo | Dropdown: Bug / Sugestão / Elogio / Outro |
| Mensagem | TextArea |
| Permitir contato | Switch |

**Ação:** `Enviar` → confirmação visual

---

*Versão 1.0*
