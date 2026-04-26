# PRD: Plano de Melhoramento Caleidoscópico – Caderno de Solo

## 1. Visão Geral
A arquitetura do Caderno de Solo foi implementada perfeitamente no padrão **Clean Architecture e Feature-First**, dividindo o sistema em Análise (Dados), Calibração (Metas e Métodos), Recomendação (Cruzamento) e Configuração (Base).
Entretanto, ao analisar o código e a usabilidade em "Ponta a Ponta", identifiquei lacunas cruciais para que o sistema se torne 100% "Real" (produção comercial) para o Eng. Agrônomo.

---

## 2. Gaps Identificados (O que Falta)

### 2.1. Gap em Recomendação: Persistência e Histórico
A tela `RecomendacaoScreen.dart` realiza todos os cálculos dinamicamente através do `CalcularRecomendacaoUseCase`. No entanto, ao final da tela:
- **Salvar Recomendação:** Os botões finais hoje disparam um *Snackbar/alerta* dizendo *"Recomendação pronta para persistência"*. O sistema **ainda não salva** o laudo final cruzado no disco ou nuvem.
- **Impacto no Histórico:** Sem salvar, a tela de Histórico (gerenciamento de clientes passados) não consegue listar os Laudos Técnicos que o Engenheiro já fez, forçando sempre um recálculo caso o agrônomo feche a tela.

### 2.2. Gap em Recomendação: Geração de Relatório PDF Técnico
Os cálculos são maravilhosos (com citações de IAC, Embrapa, Cerrados), mas estão aprisionados no Visor do Celular.
- **Exportar Arquivo:** O botão "Exportar PDF" está pendente (*"Exportação PDF será conectada no próximo passo"*). Um laudo deve ser assinado e entregue em PDF ao produtor rural.

### 2.3. Gap em Configuração: "Chumbado" vs. Dinâmico
Você relatou que o Módulo de Configuração deve gerir *"referências, dados como cálculos, referências de métricas"*.
- **Arquitetura Atual:** Hoje, equações como `FosforoFormula.nivelCriticoResina(...)`, e todos os Switch-cases do `IAC Bol. 100`, estão "chumbados" (hardcoded) nas classes de domínio (`lib/domain/formulas/`).
- **Problema Real:** Para o administrador alterar uma métrica sem atualizar o App na loja, e para que o Config cumpra seu papel de verdadeira *"Central de Referências"*, o motor precisa consultar um State/Firestore (Tabelas de Recomendação), não um código fixo.

---

## 3. Plano de Ação & Execução (Roadmap Sênior)

Recomendo atacarmos por fases estruturadas para não alucinar e manter a segurança de tipagem do sistema.

### Fase 1: Fechamento do Cíclo de Recomendação (CRUD e PDF)
**Objetivo:** Permitir salvar o laudo e entregar o PDF ao agricultor.
1. Criar `RecomendacaoEntity` e seu modelo JSON. (Salvando a fotografia exata dos resultados na data de geração: Análise + Perfil + Resultados de Doses/Parcelamentos).
2. Construir `RecomendacaoDatasource/Repository` para persistir no SQLite/Hive + Sincronismo no Firestore via App.
3. Modificar `RecomendacaoScreen` para injetar o fluxo de Salvar, roteando para a aba de **Histórico** logo após o salvamento.
4. Implementar o pacote `pdf` de Flutter em `RecomendacaoPdfGenerator`. Desenhar um layout limpo que imite a interface do app (Cabeçalho da Fazenda, Lado a lado: Análise vs Métrica, Resultados Claros, Citações Bibliográficas / Argumentações no rodapé).

### Fase 2: Painel de Histórico Robusto
**Objetivo:** Tela central para o agrônomo gerir todas as consultorias geradas.
1. Transformar o módulo Histórico atual para ler primariamente de `RecomendacaoRepository`, organizando por Cliente -> Safra.
2. Permitir buscar antigas e *re-gerar* o PDF a qualquer momento.

### Fase 3: Desacoplamento do Motor de Referências (Configuração Dinâmica)
**Objetivo:** Permitir ajustar Métodos e Níveis Críticos (NC) sob demanda no módulo de Config.
1. Criar Modelos `ReferenciaTecnicaModel` e `MetricaCulturaModel`.
2. Persistir os atuais Níveis Críticos (Fosforo_Argila, Parametros_Albrecht_Cultura) no Firestore/Hive dentro da coleção **Base de Dados** (no Config).
3. Alterar Motores (`FosforoFormula`, `CalagemEngine`) para receberem essas tabelas por Injeção de Dependência através do Riverpod. Se a Embrapa atualizar o boletim em 2027, bastará o usuário editar a Tabela/Nível crítico no painel do Config, e os resultados serão impactados de imediato, sem release nas lojas da Apple/Google.

---
**Status da Avaliação:** O documento representa a transição obrigatória do "Motor Perfeito" para um "Produto Comercial Entregável". 
Como Sênior, eu posso iniciar a **Fase 1** (Gerar a gravação no Banco e a Impressão Visual em PDF) mediante a sua autorização!
