# Arquitetura e Índice de Módulos: Caderno de Solo

Este documento descreve a estrutura atual do sistema **Caderno de Solo** (SoloForte), organizado sob os princípios de Clean Architecture e Feature-First. A principal força do sistema está no desacoplamento entre dados brutos (análise), parâmetros de especialistas (calibração) e cruzamento lógico (recomendação).

## 1. Módulo: Análise
**Objetivo:** Gerenciar a inserção e importação de laudos laboratoriais, lidando exclusivamente com os dados brutos (números qualitativos do laudo).
- **Abordagem:** Não realiza juízo de valor ("Bom", "Ruim") nem métricas agronômicas sobre fertilidade durante a edição. É apenas um repositório da verdade bruta do solo naquele momento de amostragem.
- **Implementação:** Localizado em `lib/features/analise`. Utiliza ferramentas de parsing rápido (`PdfImportService`, `IbraImportService`, etc.) para extração via OCR e Regex. Suporta formato tipo planilha (`NovaAnaliseController`) permitindo ao usuário adicionar ou corrigir rapidamente teores extraídos.

## 2. Módulo: Calibração
**Objetivo:** Permitir ao especialista criar e salvar "Perfis de Recomendação" agnósticos.
- **Abordagem:** Uma matriz de configurações onde o usuário decide as **referências** e **epocas**, bem como as **fontes** (calcário dolomítico, gesso) e **métodos corretivos** (ex: Saturação por Bases V%, Teor Absoluto de Potássio). Não há inserção de amostras neste módulo. O sistema monta o esqueleto técnico que será usado como régua e compasso.
- **Implementação:** Localizado em `lib/features/laboratorio/presentation/calibracao`. O `CalibracaoController` persiste instâncias de `CalibracaoProfile` no Hive (Local) com synching para o Firestore per-user. Mapeia chaves de configuração intensas para Cultura, Safra e Metas Albrecht.

## 3. Módulo: Recomendação
**Objetivo:** O motor agronômico propriamente dito. Une a "Análise" crua à "Calibração" definida pelo especialista.
- **Abordagem:** O usuário seleciona uma "Análise X" e um "Perfil de Calibração Y". Neste ponto, todas as métricas ganham vida.
  - A interface apresenta dados de forma emparelhada (ex: `P solo / Nível Crítico (NC): 7.0 / 30.0 mg/dm³`), deixando claro pro especialista visualmente o motivo da correção (está Abaixo do NC).
  - São geradas as formulações (t/ha de calcário, kg/ha de K2O, gessagem, etc.).
  - Inclui uma seção robusta de **Argumentos Técnicos**, fundamentando cada cálculo com as referências técnicas da calibração acoplada (Citação de Autores, como Instituto Agronômico, CFM, etc.), reforçando a autoridade do laudo gerado.
- **Implementação:** Localizado em `lib/features/laboratorio/presentation/recomendacao`. Utiliza o interactor `CalcularRecomendacaoUseCase` orquestrando calculadoras domain-driven (ex: `PotassioFormula`, `GessoEngine`). O resultado preenche o painel de leitura do `RecomendacaoScreen`.

## 4. Módulo: Configuração
**Objetivo:** Gerenciamento das tabelas-chave e bases técnicas do sistema.
- **Abordagem:** Gerencia as chaves mestres, bases de metadados, autores das citações, algoritmos de base e preferências globais. Se no futuro um boletim novo surgir e a dosagem alterar o Nível Crítico Base, o sistema ajusta essas matrizes no módulo Configuração.
- **Implementação:** Localizado em `lib/features/config`. Provê instâncias para a gestão do Firebase e sincronia local-nuvem (*offline-first*).

---

### Diagnóstico de Aderência
**Conclusão da Auditoria AI:** ✅ A arquitetura implementada no repositório **corresponde com sucesso ao fluxo mental que você idealizou**. 
1. **Dados Isolados (Análise):** O repositório reflete uma blindagem do `AnaliseSolo`. Nenhuma regrinha de recomendação reside no input do solo hoje.
2. **Setup Standalone (Calibração):** O `CalibracaoProfile` está de fato sendo salvo offline/online como um gabarito totalmente independente sem forçar ligação a uma amostra durante sua edição.
3. **Câmara de Junção (Recomendação):** A tela `RecomendacaoScreen` atua estritamente como a "esteira de montagem", pareando o que o laboratório encontrou com as Metas que você calibrou (Métrica x Resultado), apresentando claramente as fundamentações (citando manuais) e bloqueios contra antagonismos do solo.

*Gerado dinamicamente via AI Audit Engine – Caderno de Solo / SoloForte.*
