# CADERNO DE SOLO
## Product Requirements Document
### Calibração Padrão Albrecht + Y · Tela Grid de Seleção

| Campo | Valor |
|---|---|
| Versão | 1.0 |
| Data | 11 de abril de 2026 |
| Status | **Aprovado para implementação** |
| App | Caderno de Solo (Flutter/iOS) |
| Feature | Lab > Calibração |

---

## 1. Visão Geral

Este PRD descreve dois incrementos de produto na tela de Calibração do app Caderno de Solo:

- **Perfil padrão pré-configurado "Albrecht + Y"** — criado automaticamente na primeira abertura do app, sem necessidade de configuração manual pelo agrônomo.
- **Tela de seleção em grid de cards iOS** — substitui a abertura direta do formulário por uma galeria visual de calibrações salvas.

### 1.1 Problema

Ao abrir a aba Calibração pela primeira vez, o agrônomo encontra um formulário em branco com dezenas de parâmetros para preencher. Não existe nenhuma referência de partida, gerando atrito no onboarding e risco de configurações incorretas. Adicionalmente, não há forma visual clara de navegar entre múltiplos perfis de calibração salvos.

### 1.2 Solução

Entregar um perfil de referência completo (Albrecht + Y, soja, Cerrado) pré-carregado no primeiro acesso, combinado com uma tela de seleção em estilo iOS grid, tornando a experiência intuitiva e profissional desde o primeiro uso.

---

## 2. Escopo da Entrega

| Funcionalidade | Tipo | Prioridade | Status |
|---|---|---|---|
| Perfil padrão Albrecht + Y | Nova feature | P0 — Crítico | ✅ Implementado |
| Flag `calibracao_seeded` | Infraestrutura | P0 — Crítico | ✅ Implementado |
| `CalibracaoSeletorPage` (grid) | Nova tela | P0 — Crítico | ✅ Implementado |
| Router `/lab/calibracao` | Refactor | P0 — Crítico | ✅ Implementado |
| `calibracao_padrao.dart` | Novo arquivo | P0 — Crítico | ✅ Implementado |
| Long press — menu contextual | UX | P1 — Importante | Prompt separado |
| Duplicar calibração | Feature | P1 — Importante | Prompt separado |

---

## 3. Feature 1 — Perfil Padrão Albrecht + Y

### 3.1 Regra de negócio

- O perfil é criado **APENAS** quando o box Hive `calibracao_profiles_box` estiver vazio.
- Uma flag separada `calibracao_seeded` é gravada no Hive após a criação.
- Se o usuário deletar todas as calibrações depois, o perfil **NÃO** é recriado.
- O perfil é salvo como `CalibracaoProfile` com `parametrosCards` preenchido.

### 3.2 Arquivos

| Ação | Arquivo |
|---|---|
| Criado | `lib/features/lab/calibracao/data/calibracao_padrao.dart` |
| Modificado | `lib/data/datasources/local/calibracao_hive_datasource.dart` |
| Modificado | `lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart` |
| Criado | `lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart` |
| Modificado | `lib/core/constants/app_routes.dart` |
| Modificado | `lib/core/router/app_router.dart` |

### 3.3 Identificação do perfil

| Campo | Valor |
|---|---|
| Nome | **Albrecht + Y** |
| Cultura | Soja |
| Safra | atual |
| Cliente | pré configuração |

---

### 3.4 Card 1 — Calagem

| Parâmetro | Valor |
|---|---|
| Tipo de calagem | Corretiva |
| Tipo de calcário | Dolomítico |
| CaO / MgO | 30% / 18% |
| PN / RE / PRNT | 90% / 90% / 90% |
| Usar 2º calcário | Não |
| **Método de calagem** | **⑥ Albrecht + Y** |
| Ca alvo / NC Ca mín | 55% / 2,5 |
| Mg alvo / NC Mg mín | 22% / 1,1 |
| K alvo / NC K mín | 3% / 0,22 |
| Na (usar meta) | Sim |
| V% implícito | 80% |
| NC Albrecht / Y solo | 1,75 t/ha / 1,75 t/ha |
| Incorporação | Grade pesada 32" — folga 15 cm |
| Superfície contato | 80% superfície PD |
| Mês de aplicação | Março |

---

### 3.5 Card 1 — Gesso

| Parâmetro | Valor |
|---|---|
| Usar gesso | Sim |
| Método | ① EMBRAPA / Souza et al. (2004) — argila % |
| Teor Ca / Teor S | 20% / 15% |

---

### 3.6 Card 2 — Fósforo

| Parâmetro | Valor |
|---|---|
| Extrator | Mehlich-1 |
| Referência | Embrapa Cerrado |
| NC | 15 mg/dm³ (bloqueado pela tabela) |
| Tabela argila (Sousa & Lobato, 2004) | <10%→15 · 10–20%→15 · 21–40%→8 · 41–60%→4 · >60%→3 |
| Camada | 0–20 cm |
| Modo de cálculo | Correção do solo |
| Cultivar / Tipo | Soja / Exportação |
| % P do solo | 100,0 |

---

### 3.7 Card 3 — Potássio

| Parâmetro | Valor |
|---|---|
| Extrator | Mehlich-1 |
| Referência | Embrapa Cerrado |
| Critério NC | Ambos — usar o maior |
| NC teor / NC % CTC | 46 mg/dm³ / 3% (bloqueados) |
| Camada | 0–20 cm |
| Modo de cálculo | Manutenção |
| Modo de aplicação | Lanço plantio direto |
| FEK | 80,0% |

---

### 3.8 Card 4 — Micronutrientes

**Grupo de Aplicação**

| Parâmetro | Valor |
|---|---|
| Nome | foliares |
| Via | Foliar |
| Elementos | B, Cu, Mn, Zn, Mo, Co, Ni, Se — **Fe fora do grupo** |
| Fonte / Produto | carbonatos e fontes nobres |
| Eficiência esperada | 90% |

**Nutrientes Individuais** — chaves reais do `parametrosCards`

| Elem. | Extrator | Referência | NC | Via | Fonte Solo | Fonte Foliar |
|---|---|---|---|---|---|---|
| **B** | DTPA-TEA | EMBRAPA Soja | 1,0 | Ambas | borato Ca/Na · teor 100% · efic. 90% | boro protegido · 0,5% · efic. 80% · 2000 g/ha |
| **Cu** | Resina | EMBRAPA Soja | 0,8 | Foliar | — | óxido cubroso · 500% · efic. 80% · 50 g/ha |
| **Fe** | Água quente | Motor de Cál. | 0 | Solo | Sulfato ferroso · 20% · efic. 30% · corr. 0% | — |
| **Mn** | Água quente | Motor de Cál. | 6,0 | Foliar | — | carbonato de manganes · 30% · efic. 80% · 600 g/ha |
| **Zn** | Água quente | Motor de Cál. | 0,91 | Foliar | — | carbonato de zinco · 23% · efic. 70% · 200 g/ha |
| **Mo** | Oxalato NH4 | Motor de Cál. | 0,1 | Ambas | Molibdato sódio · 39% · efic. 70% | Molibdato sódio · 39% · efic. 90% · 40 g/ha |
| **Co** | Água quente | Motor de Cál. | 0,05 | Ambas | Sulfato cobalto · 21% · efic. 50% | Sulfato cobalto · 21% · 3 g/ha |
| **Ni** | Água quente | Motor de Cál. | 0,1 | Ambas | Sulfato níquel · 22% · efic. 50% | Sulfato níquel · 22% · efic. 70% · 5 g/ha |
| **Se** | Água quente | Motor de Cál. | 0,05 | Ambas | Selenato sódio · 45% · efic. 50% | Selenato sódio · 45% · efic. 70% · 5 g/ha |

> ⚠️ **Fe** — `adicionarGrupo: false` · NC = 0 · `percentualCorrecaoSolo: 0`
> ✅ **B e Se** — `adicionarGrupo: true` · `grupoId` → `foliares`
> ✅ **Cu** — `adicionarGrupo: true` · via apenas Foliar (sem campos de solo)

---

## 4. Feature 2 — Tela Grid de Seleção

### 4.1 Comportamento

- `CalibracaoSeletorPage` é o destino da rota `/lab/calibracao`.
- `CalibracaoPage` (formulário existente) é acessada via `/lab/calibracao/editar`.
- O grid exibe todos os `CalibracaoProfile` salvos no Hive.
- O último card do grid é sempre o card fixo **Nova calibragem**.

### 4.2 Especificação visual — iOS

| Elemento | Especificação |
|---|---|
| Fundo | `AppColors.bgSecondary` — #F5F5F7 |
| Título AppBar | "Calibração" — cor `AppColors.primary` #007AFF |
| Grid | `GridView` · crossAxisCount: 2 · childAspectRatio: 1.0 |
| Padding | 16px todos os lados |
| Espaçamento | mainAxisSpacing: 12 · crossAxisSpacing: 12 |

**Card de calibração salva**

| Elemento | Especificação |
|---|---|
| Background | white · border-radius: 12px |
| Sombra | BoxShadow · black 6% opacity · blurRadius: 8 |
| Ícone | `Icons.extension` (quebra-cabeça) · 48px · #007AFF |
| Nome | fontSize: 13 · fontWeight: w500 · abaixo do ícone |
| Tap | Navega para `CalibracaoPage` (edição) |
| Long press | Menu contextual: Editar / Duplicar / Excluir **(P1 — prompt separado)** |

**Card Nova calibragem**

| Elemento | Especificação |
|---|---|
| Background | white · borda tracejada 2px dashed #D1D1D6 |
| Ícone | `Icons.add_circle` · 48px · #34C759 (verde iOS) |
| Texto | "Nova calibragem" · fontSize: 13 · cor #86868B |
| Posição | Sempre o último item do grid |
| Tap | Abre `CalibracaoPage` em branco |

### 4.3 Router

| Antes | Depois |
|---|---|
| `/lab/calibracao` → `CalibracaoPage()` | `/lab/calibracao` → `CalibracaoSeletorPage()` |
| — | `/lab/calibracao/editar` → `CalibracaoPage()` |
| — | `AppRoutes.labCalibracaoEditar = '/lab/calibracao/editar'` |

---

## 5. Mapeamento Técnico Crítico

### 5.1 Chaves reais do `parametrosCards['micros']['elementos']`

| Chave no Map | Tipo | Linha no widget |
|---|---|---|
| `simbolo` | String | `defaultMicros()` |
| `extrator` | String | L 1161 |
| `referencia` | String | L 1184 |
| `ncSolo` | double | L 1213 |
| `viaAplicacao` | String | L 1227 |
| `percentualCorrecaoSolo` | double | L 1249 |
| `teorFonteSolo` | double | L 1262 |
| `fonteSolo` | String | L 1277 |
| `eficienciaSolo` | double | L 1290 |
| `doseElementoFoliar` | double | L 1306 |
| `teorFonteFoliar` | double | L 1318 |
| `fonteFoliar` | String | L 1333 |
| `eficienciaFoliar` | double | L 1346 |
| `temAnaliseFoliar` | bool | L 1360 |
| `adicionarGrupo` | bool | `defaultMicros()` |
| `grupoId` | String | aponta para `id` do grupo na lista `grupos` |

### 5.2 Mapeamento prompt → chaves reais

| Nome no prompt | Chave real no código |
|---|---|
| `nc` | `ncSolo` |
| `correcaoSolo` | `percentualCorrecaoSolo` |
| `doseElementoPuro` | `doseElementoFoliar` |
| `via` | `viaAplicacao` |
| `adicionarAGrupo` | `adicionarGrupo` |
| `teorFoliarDisponivel` | `temAnaliseFoliar` |

---

## 6. Restrições

### Não alterar
- Estrutura da `CalibracaoEntity` (modelo legado — não usado pelo controller)
- Lógica de cálculo do `RecomendacaoEngine`
- Qualquer tela fora do escopo desta feature
- Limite de 7 dígitos em inputs numéricos (`AppInputNumerico`)

### Obrigatório
- Todos os textos em PT-BR
- Visual segue `AppColors`, `AppTextStyles` e `AppCard` do design system iOS
- NÃO usar `BottomSheet` nem `Dialog` para navegação entre calibrações
- Loading state: `CircularProgressIndicator` centralizado enquanto Hive carrega

---

## 7. Critérios de Aceite

### 7.1 Perfil padrão

1. Novo usuário: ao abrir Calibração, o perfil **Albrecht + Y** existe e está preenchido.
2. Usuário existente com calibrações: nenhuma alteração no estado atual.
3. Usuário que deletou tudo: perfil **NÃO** é recriado automaticamente.
4. Todos os 9 nutrientes visíveis com valores corretos no card Micronutrientes.

### 7.2 Tela grid

1. Rota `/lab/calibracao` exibe `CalibracaoSeletorPage` com grid de cards.
2. Card Albrecht + Y aparece com ícone quebra-cabeça azul.
3. Card Nova calibragem é sempre o último, com ícone + verde.
4. Tap em qualquer card navega corretamente para `CalibracaoPage`.

### 7.3 Comandos de verificação pós-implementação

```bash
# Verificar arquivos criados
grep -r "calibracaoPadrao\|calibracao_padrao" lib/ --include="*.dart" -l

# Verificar tela seletor
grep -r "CalibracaoSeletorPage" lib/ --include="*.dart" -l

# Verificar import correto no controller
grep -n "import.*calibracao_padrao" \
  lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
```

---

## 8. Fora do Escopo — Próximos Prompts

| Feature | Descrição | Prioridade |
|---|---|---|
| Long press menu | Editar / Duplicar / Excluir via ContextMenu | P1 |
| Duplicar calibração | Clonar perfil com novo nome | P1 |
| Sincronização Firestore | Perfis ainda são apenas locais (Hive) | P2 |
| Outros perfis padrão | Ex: Saturação de Bases Cerrado, EMBRAPA | Backlog |

---

*Caderno de Solo · PRD v1.0 · 11/04/2026*
