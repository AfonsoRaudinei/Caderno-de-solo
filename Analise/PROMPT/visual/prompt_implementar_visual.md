# Prompt: Implementar Tela Calibração + Recomendação (Visual Completo)
**SoloForte · Agente Antigravity**
**Leia SOLOFORTE_FLUXO_ARQUITETURA.md ANTES de começar**

---

## Contexto

A tela de Calibração existe mas está genérica.
A tela de Recomendação está mockada.
Este prompt implementa os dois visualmente com dados reais.

---

## PARTE 1 — Tela Calibração (`lib/features/lab/calibracao/`)

### 1.1 Cabeçalho da Calibração

Substituir o cabeçalho atual por:

```dart
// Campos do cabeçalho — todos em CalibracaoState
String nome;          // obrigatório
String cultura;       // Dropdown: Soja / Milho / Feijão / Algodão — obrigatório
String safra;         // ex: 2026/2027
String cliente;
String fazenda;
String talhao;

// Dropdown no topo com perfis salvos
// Botões: + Novo | Salvar | Salvar como novo | Duplicar | Excluir
```

Layout:
```
[Dropdown: Perfis salvos ▼]          [+ Novo]
Nome          [AppInput]
Cultura       [AppDropdown: Soja/Milho/Feijão/Algodão]
Safra         [AppInput]
Cliente       [AppInput]
Fazenda       [AppInput]
Talhão        [AppInput]
```

---

### 1.2 Card 1 — Corretivos (Calcário + Gesso)

Expandir o card atual com os campos completos:

```
TIPO DE CALAGEM
[Segmented: Corretiva ●  Manutenção PD]

─── CALCÁRIO ───────────────────────────────

Tipo de calcário    [AppDropdown]
                    Dolomítico / Calcítico / Magnesiano /
                    Calcinado / Filler / Personalizado

CaO (%)  [AppInput 7 dígitos]   MgO (%)  [AppInput 7 dígitos]
PN  (%)  [AppInput 7 dígitos]   RE  (%)  [AppInput 7 dígitos]
PRNT (%) [calculado auto — editável]

Score de qualidade: [barra visual ■■■□□]
PN: XX% · RE: XX% · Residual: XX%
[dica contextual por época]

Usar 2º calcário?  [Toggle]
└─ [mesmos campos + Proporção 1º (%)]
   PRNT ponderado: XX%

MÉTODO DE CALAGEM  [AppDropdown]
─ Se Corretiva: ①V% ②EMBRAPA ③Ca+Mg ④Supercalagem ⑤Albrecht ⑥AlbrechtY ⑦CorrecaoMg
─ Se Manutenção PD: ①V% ⑤Albrecht ⑥AlbrechtY

─ Parâmetros do método ─
[Se ①] V₂ desejado (%)    [AppInput — sugestão por cultura]
[Se ②] Fator H+Al         [AppInput — padrão 0,5]
[Se ④] Dose fixa (t/ha)   [AppInput]
[Se ⑦] Mg desejado        [AppInput]

─ BLOCO ALBRECHT (visível só quando ⑤ ou ⑥) ─
Cultura: [label da cultura selecionada no cabeçalho]

          Meta (%)          NC Mínimo (cmolc/dm³)
Ca alvo   [AppInput: 65]    Ca mín  [AppInput: 2,0]
Mg alvo   [AppInput: 15]    Mg mín  [AppInput: 0,8]
K  alvo   [AppInput:  4]    K  mín  [AppInput: 0,15]
Na [Toggle off]

V% implícito: [calculado] — [badge: ✅ Adequado / ⚠️ Fora da faixa]

PAINEL DE DÉFICITS (tempo real — quando há análise vinculada)
Base  Atual   Alvo    Déficit
Ca    X,X  →  X,X     X,X cmolc/dm³
Mg    X,X  →  X,X     X,X cmolc/dm³
K     X,XX →  X,XX    X,XX cmolc/dm³
V%: XX%  →  XX%

[Se ⑥] PAINEL Y
NC Albrecht: X,XX t/ha
Y do solo:   X,XX t/ha
→ Dose base: X,XX t/ha  [🛡️ Y prevalece / ✅ Albrecht adequado]

─── INCORPORAÇÃO ──────────────────────────────

Método de incorporação  [AppDropdown]
  Sem incorporação / Grade leve / Grade pesada /
  Arado disco / Escarificador

[Se Grade]
  Tipo de grade  [AppDropdown: 22" / 24" / 26" / 28" / 32"]
  Folga mancal (cm)  [AppInput: 25]
  Profundidade estimada: XX,X cm
  Fator p: X,XX

[Outros implementos]
  Profundidade (cm)  [AppInput]
  Fator p: [calculado]

Superfície de contato  [AppDropdown]
  100% incorporado total / 90% incorporado parcial /
  85% superfície com chuva / 80% superfície PD

Mês de aplicação  [AppDropdown: Jan–Dez]
Dias disponíveis: XX dias  [badge época]

─── GESSO ─────────────────────────────────────

Vai usar gesso?  [Toggle]
[Se sim]
  Método  [AppDropdown: ①EMBRAPA ②UFLA ③Vitti ④Caires]
  Teor Ca (%)  [AppInput: 20]
  Teor S (%)   [AppInput: 15]
  Dados subsolo: vêm da Análise automaticamente
  [badge diagnóstico: 🟡 indicado / ✅ não indicado]
```

---

### 1.3 Card 2 — Fósforo

```
Extrator          [AppDropdown: Resina IAC / Mehlich-1 / Mehlich-3]
Referência        [AppDropdown: IAC Bol.100 / EMBRAPA Cerrado /
                               UFLA / EMBRAPA Soja / Personalizada]
NC (mg/dm³)       [AppInput — carregado automático, editável]
Camada            [AppDropdown — camadas da análise]

MODO DE CÁLCULO   [AppDropdown]
  ① Correção do solo
  ② Extração

[Se ①]
  % de correção por ciclo  [AppInput: 100]
  Fator solo (por textura) [AppInput — carregado automático]

[Se ②]
  Cultivar: [label + botão link → Culturas]
  Tipo: [AppDropdown: Exportação / Extração total]
  % P do solo que vai usar  [AppInput: 0]

APLICAÇÃO
  Modo  [AppDropdown: Sulco / Lanço incorporado /
                      Lanço sem incorp. / Fertirrigação]
  FEP (%)  [AppInput — carregado por textura, editável]
```

---

### 1.4 Card 3 — Potássio

```
Extrator          [AppDropdown: Resina IAC / Mehlich-1 / Mehlich-3]
Referência        [AppDropdown: mesmas do P]
Critério NC       [AppDropdown: Teor absoluto / % K na CTC / Ambos]
NC                [AppInput — carregado automático, editável]
Camada            [AppDropdown]

MODO DE CÁLCULO   [AppDropdown: ① Correção / ② Extração]

[Se ①]
  % de correção por ciclo  [AppInput: 100]

[Se ②]
  Cultivar: [label + botão link → Culturas]
  Tipo: [AppDropdown: Exportação / Extração total]
  % K do solo que vai usar  [AppInput: 0]

APLICAÇÃO
  Modo  [AppDropdown: Lanço incorporado / Lanço sem incorp. /
                      Sulco / Cobertura / Fertirrigação]
  FEK (%)  [AppInput — carregado por textura, editável]

[Se cultura = Algodão]
  ⚠️ badge: "Algodão: NC ajustado para 5% CTC, FEK 60%"
```

---

### 1.5 Card 4 — Micronutrientes

```
[+ Criar Grupo de Aplicação]  ← botão no topo

Para cada elemento (B, Cu, Fe, Mn, Zn, Mo, Co, Ni, Se):
Sub-card expansível com header colorido por elemento:

  ── B — Boro ─────────────────────────── ▼ ──
  Extrator     [AppDropdown]
  Referência   [AppDropdown]
  NC (mg/dm³)  [AppInput — carregado automático]
  [badge classe: Baixo / Médio / Alto]

  Via de aplicação  [AppDropdown: Solo / Foliar / TS / Ambas]

  [Se Solo]
    % correção     [AppInput: 100]
    Fonte solo     [AppDropdown]
    Teor (%)       [AppInput — carregado]
    Eficiência (%) [AppInput — carregado]

  [Se Foliar ou TS]
    Dose elemento puro (g/ha)  [AppInput]
    Fonte foliar   [AppDropdown]
    Teor (%)       [AppInput — carregado]
    Eficiência (%) [AppInput — carregado]

  Teor foliar disponível?  [Toggle]
  [Se sim] Teor foliar (mg/kg)  [AppInput]

  Adicionar a grupo?  [Toggle → AppDropdown grupo]

─── GRUPOS DE APLICAÇÃO ─────────────────────
[Grupo 1: B + Zn + Cu — Foliar]  ▼
  Nome do grupo    [AppInput]
  Via              [AppDropdown: Foliar / Solo / TS]
  Elementos        [MultiSelect: checkboxes]
  Fonte/produto    [AppDropdown ou "Mistura manual"]
  Eficiência grupo (%)  [AppInput]
```

---

### 1.6 Rodapé

```
[Salvar Calibração]          [Duplicar]
Última atualização: [timestamp]
```

---

## PARTE 2 — Tela Recomendação (`lib/features/lab/recomendacao/`)

Substituir o mock atual pela tela real:

### 2.1 Cabeçalho da Recomendação

```
─── Recomendação ──────────────────────────────

Selecionar Análise de Solo  [AppDropdown — lista de análises salvas]
Selecionar Calibração       [AppDropdown — lista de calibrações salvas]

[Gerar Recomendação]  ← botão azul primário
```

### 2.2 Resultado (aparece após gerar)

```
─── IDENTIFICAÇÃO ─────────────────────────────
Cliente: [da calibração]
Fazenda: [da calibração]  · Talhão: [da calibração]
Cultura: [da calibração]  · Safra: [da calibração]
Análise: [lab + data coleta]
Calibração: [nome da calibração]

─── CALCÁRIO ──────────────────────────────────
Método: [⑥ Albrecht (Y)]
Dose: [XX,X t/ha]  ← destaque azul grande

V% atual: XX%  →  V% esperado: XX%
Ca: X,X → X,X cmolc/dm³
Mg: X,X → X,X cmolc/dm³
Relação Ca:Mg: X,X:1  [badge: Adequada / Estreita / Larga]

[Se parcelamento sugerido]
  📋 Aplicação 1: XX% = X,X t/ha — [mês]
     Aplicação 2: XX% = X,X t/ha — [mês]

─── GESSO ─────────────────────────────────────
[Se indicado]
Dose: XXXX kg/ha
S fornecido: XXX kg/ha  · Ca fornecido: XXX kg/ha

─── FÓSFORO ───────────────────────────────────
Modo: [Correção / Extração]
P solo: XX mg/dm³  · NC: XX mg/dm³
Dose: XXX kg P₂O₅/ha  ← destaque vermelho

[Se Legacy P]
⚠️ Solo acima do NC — dose mínima de manutenção aplicada

─── POTÁSSIO ──────────────────────────────────
Critério: [Teor absoluto / % CTC]
K solo: XX mg/dm³  · NC: XX mg/dm³
Dose: XXX kg K₂O/ha  ← destaque laranja

Relação K:Mg: X,X  [badge aviso se crítico]
Relação K:Ca: X,X  [badge aviso se crítico]

─── MICRONUTRIENTES ───────────────────────────
[Para cada elemento com dose > 0]
B:  XXX g/ha  via [foliar] — Fonte: [ácido bórico] — XX g/ha produto
Zn: XXX g/ha  via [solo]   — Fonte: [sulfato zinco] — X,X kg/ha produto
...

[Para cada grupo]
📦 Grupo 1: B + Zn + Cu — Foliar
   Produto: [nome]  Dose: X,X kg/ha
   Fornece: B XXg/ha · Zn XXg/ha · Cu XXg/ha

─── AVISOS ────────────────────────────────────
[Lista de badges ⚠️ ℹ️ gerados pelo motor]

─── ARGUMENTOS TÉCNICOS ───────────────────────
[Texto gerado automaticamente explicando cada decisão]
Ex: "A relação Ca:Mg resultante de 4,2:1 indica equilíbrio
     adequado para soja em Cerrado..."

[Salvar Recomendação]     [Exportar PDF]
```

---

## Regras de Implementação

1. **Calibração não calcula** — apenas armazena parâmetros no `CalibracaoState`
2. **Recomendação calcula** — ao tocar "Gerar", chama `CalcularRecomendacaoUseCase`
   passando `CalibracaoEntity` + `AnaliseEntity`
3. **Todos os inputs: max 7 dígitos**
4. **Cards fechados por padrão** — abrem ao toque no header
5. **Campos auto-preenchidos são editáveis** — nunca travados
6. **Avisos como banners descartáveis** — nunca bloqueiam
7. **Bloco Albrecht**: visível SOMENTE quando método ⑤ ou ⑥ selecionado
8. **Campos modo P/K**: visíveis SOMENTE para o modo selecionado (① ou ②)

---

## Após implementar

Execute:
```
flutter analyze
flutter test
```

Zero erros antes de considerar concluído.

---

*Prompt: implementar_calibracao_recomendacao_visual.md*
*SoloForte · Março 2026*
