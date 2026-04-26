# Guia do Sistema de Métricas Dinâmicas (Eterno) ♾️

Este documento descreve a nova arquitetura do SoloForte que permite a calibração de todo o motor agronômico sem a necessidade de novos deploys.

## 🏗️ Arquitetura
O sistema utiliza uma abordagem **Offline-First** com **Injeção de Constantes**, abandonando os `switch-cases` rígidos no código.

### 1. Camada de Domínio (`TabelaMetricas`)
As referências técnicas (Níveis Críticos, FEP, FEK, Fator Solo, Metas Albrecht, SMP, V%) agora são tratadas como entidades persistíveis.
- **Busca por Faixa**: O sistema encontra o valor correto automaticamente com base no teor de argila ou pH da análise de solo.
- **Estrutura Flexível**: Suporta múltiplos extratores (Resina, Mehlich-1) e regiões (Cerrado, RS/SC, Sudeste).

### 2. Motores de Cálculo Refatorados
- **`FosforoFormula`**: Agora recebe NC, FEP e Fator Solo via parâmetros injetados.
- **`PotassioFormula`**: Consome limites de antagonismo (K:Mg, K:Ca) e NC absoluto de forma dinâmica.
- **`CalcarioFormula`**: Permite override de metas de saturação (Albrecht) e tabelas SMP por estado.

### 3. Gerenciamento de Estado (Riverpod)
O `tabelaMetricasProvider` centraliza as regras. Se o usuário resetar os dados, o sistema recarrega os padrões bibliográficos da EMBRAPA/IAC via `TabelaMetricasDefaults`.

---

## 🛠️ Como Calibrar o Sistema (via UI)

O Agrônomo pode acessar o menu **Gerenciamento > Tabelas de Métricas Agronômicas** para:

1.  **Ajustar Níveis Críticos**: Se a Embrapa atualizar o NC de P para solos argilosos, basta editar a linha correspondente.
2.  **Personalizar FEP/FEK**: Ajustar a eficiência de fontes de fertilizantes para a realidade da sua região.
3.  **Configurar Alertas de Antagonismo**: Definir quando o sistema deve avisar sobre o excesso de Potássio em relação ao Magnésio.
4.  **Restaurar Padrão**: Caso ocorra erro na calibragem manual, é possível restaurar os "Valores de Fábrica" a qualquer momento.

---

## 🚀 Impacto Operacional
- **Deploys Zero**: Mudanças técnicas não exigem atualização na App Store.
- **Argumentação Técnica**: O motor agora é 100% transparente, permitindo que o agrônomo valide exatamente quais referências estão sendo usadas para gerar a recomendação.

---
> [!TIP]
> O sistema salva uma "foto" das métricas usadas no momento da Recomendação no Histórico, garantindo integridade documental futura.
