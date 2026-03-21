# Manual de Boas Práticas em Flutter/Dart

## 1. Introdução

Este manual reúne boas práticas para desenvolvimento de aplicações em Flutter utilizando a linguagem Dart, com foco em código limpo, manutenível, performático e escalável.[web:1][web:5][web:8]

Os tópicos abordam desde estilo de código e organização de projetos até arquitetura, gerência de estado, performance, testes, segurança e automação.

---

## 2. Fundamentos de Dart e estilo de código

### 2.1. Use o guia "Effective Dart"

- Siga as recomendações oficiais de estilo, design e documentação do "Effective Dart" (style, usage, design e documentation).[web:1][web:7]
- Adote convenções consistentes de nomes para classes, métodos, variáveis e constantes, reforçando a legibilidade do código.[web:1]

### 2.2. Formatação automática de código

- Utilize o comando `dart format` ou a integração do formatador na IDE para manter o código padronizado.
- Configure o projeto para que o formatador seja executado automaticamente em *pre-commit* ou *pre-push*.

### 2.3. Linting e análise estática

- Ative regras de lint oficiais (`flutter_lints` ou `lint` customizados) via `analysis_options.yaml` para reforçar boas práticas e capturar problemas cedo.[web:4][web:8][web:10]
- Rode `flutter analyze` regularmente (ou em CI) para identificar *code smells*, imports não usados, problemas de tipo e padrões desaconselhados.[web:10]

### 2.4. Convenções essenciais de estilo

- Indentação com 2 espaços, linhas com comprimento moderado (80–100 caracteres) e uso apropriado de espaços em torno de operadores, vírgulas e chaves.[web:1][web:4][web:10]
- Use `final` para variáveis que não serão reatribuídas e `const` para constantes de tempo de compilação, reduzindo mutabilidade desnecessária e melhorando a segurança do código.[web:4]
- Prefira coleções imutáveis quando os dados não devem mudar, evitando bugs por modificações acidentais.[web:4]
- Use o operador de cascata (`..`) para encadear chamadas em um mesmo objeto quando isso melhorar a clareza.[web:4]

---

## 3. Organização de projeto Flutter

### 3.1. Estrutura de pastas clara

- Separe camadas por responsabilidade, por exemplo: `lib/data` (fontes de dados, models), `lib/domain` (regras de negócio, use cases) e `lib/presentation` (UI, widgets, gerência de estado).[web:8]
- Em projetos maiores, considere organizar também por *feature* (ex.: `features/auth`, `features/products`) contendo subpastas `data`, `domain` e `presentation` para manter o contexto coeso.[web:8]

### 3.2. Arquivos pequenos e focados

- Mantenha arquivos com responsabilidades claras e tamanho moderado; quebre widgets e classes grandes em componentes menores e reutilizáveis.[web:8]
- Evite funções gigantes; extraia métodos privados bem nomeados para melhorar a leitura e facilitar testes.

### 3.3. Separação entre camadas

- Evite acesso direto à rede, banco de dados ou *shared preferences* a partir de widgets.
- Centralize a lógica de dados em *repositories* e *data sources* na camada `data`, expondo casos de uso (use cases) na camada `domain` para consumo pela camada de apresentação.[web:8]

---

## 4. Widgets e composição de UI

### 4.1. Prefira composição a herança

- Construa UIs a partir de widgets pequenos e especializados, combinando-os em widgets maiores em vez de criar hierarquias de herança complexas.
- Reaproveite widgets entre telas para manter consistência visual e facilitar manutenção.

### 4.2. Stateless vs Stateful

- Use `StatelessWidget` sempre que possível; mova para `StatefulWidget` apenas quando houver estado interno que realmente dependa do ciclo de vida do widget.[web:9]
- Mantenha o método `build` leve; evite lógicas pesadas ou chamadas de rede dentro do `build`, usando em vez disso `initState`, `FutureBuilder`, gerência de estado ou *streams*.[web:3][web:5]

### 4.3. Widgets reutilizáveis e parametrizados

- Crie widgets parametrizados com propriedades claras (ex.: `title`, `onPressed`, `isLoading`) para facilitar reutilização.
- Evite *duplicar* layout; extraia padrões recorrentes (cards, botões, listas) em widgets compartilhados.

### 4.4. Layouts eficientes

- Evite árvores de widgets profundamente aninhadas; use `Row`, `Column`, `Flex`, `Stack` e outros layouts básicos de forma balanceada.[web:6]
- Use widgets de *layout builder* (como `LayoutBuilder`) apenas quando necessário, pois podem gerar mais passes de layout.[web:5]

---

## 5. Gerência de estado

### 5.1. Escolha de abordagem

- Para UIs simples, `setState` pode ser suficiente, desde que o estado fique próximo de onde é usado.
- Para aplicações médias ou grandes, adote um padrão de gerência de estado escalável (Provider, Riverpod, BLoC, MobX, Redux etc.).[web:3][web:6]
- Evite misturar múltiplos padrões sem necessidade; padronize em torno de 1 ou 2 abordagens bem documentadas.

### 5.2. Boas práticas comuns

- Mantenha o estado reativo e previsível; evite acessar estado global sem controle.
- Separe lógica de negócio da camada de apresentação: blocos, controladores ou *notifiers* devem conter regras de negócio, enquanto widgets apenas reagem ao estado.
- Use imutabilidade quando possível, criando novos estados em vez de mutar objetos existentes, facilitando *debug* e testes.[web:4][web:8]

### 5.3. Desempenho na gerência de estado

- Evite reconstruir toda a árvore de widgets ao mudar um pequeno pedaço de estado; use seletores, `Consumer`, `Selector` ou `Provider` específicos para granularidade fina.[web:3][web:6]
- Use `RepaintBoundary` quando tiver partes independentes da UI que podem ser isoladas para evitar repaints desnecessários.[web:3][web:5]

---

## 6. Performance e otimização

### 6.1. Medir antes de otimizar

- Utilize DevTools, o modo *profile* e ferramentas de performance para analisar FPS, tempo de build de widgets, uso de CPU e *jank* antes de otimizar.[web:3][web:5][web:12]
- Focalize otimizações em pontos quentes identificados (telas pesadas, animações lentas, listas extensas) em vez de alterações prematuras em todo o app.[web:6]

### 6.2. Boas práticas gerais de performance

- Use `const` em widgets imutáveis sempre que possível para evitar reconstruções desnecessárias.[web:6]
- Prefira `ListView.builder`, `GridView.builder` e outros *builders* para listas longas, construindo apenas os itens visíveis na tela.[web:5][web:15]
- Evite operações pesadas (cálculos intensivos, parsing grande de JSON, compressão) na *main isolate*; use `compute` ou isolates dedicadas para manter a UI responsiva.[web:6][web:15]

### 6.3. Layout e rendering

- Entenda a regra básica de layout do Flutter: "Constraints go down, sizes go up, parent sets position" e evite *intrinsic passes* desnecessários.[web:5]
- Minimize o uso de widgets que forçam múltiplos passes de layout (como certos layouts intrínsecos) em grandes listas ou grades.[web:5]
- Use *lazy loading* para dados e imagens, carregando apenas o que for necessário em cada momento.[web:5][web:6]

### 6.4. Tempo de frame

- Busque construir e renderizar frames em até 16 ms em telas de 60 Hz (idealmente menos), para animações suaves e melhor consumo de bateria.[web:5][web:6]
- Teste em dispositivos de menor capacidade, garantindo boa experiência mesmo em hardware limitado.[web:5]

---

## 7. Rede, dados e cache

### 7.1. Boas práticas de chamadas de API

- Use bibliotecas consolidadas para HTTP (como `dio` ou `http`) com interceptors para logging, autenticação e *retry* quando necessário.[web:8]
- Implemente tratamento robusto de erros, diferenciando falhas de rede, tempo excedido, erros de servidor e erros de validação, exibindo mensagens claras ao usuário.[web:8]

### 7.2. Cache e armazenamento local

- Utilize `shared_preferences`, Hive, ObjectBox ou outras soluções locais para cache de dados acessados com frequência.[web:8]
- Defina políticas de expiração de cache e estratégias de atualização (ex.: *stale-while-revalidate*), evitando dados desatualizados.

### 7.3. Otimização de rede

- Envie e receba apenas os campos necessários em cada requisição, reduzindo tamanho de payloads.[web:8][web:3]
- Considere compressão (ex.: gzip) em APIs que trafegam grandes volumes de dados.[web:8]

---

## 8. Testes e qualidade de código

### 8.1. Tipos de testes em Flutter

- Escreva testes unitários para regras de negócio (use cases, blocos, services), garantindo o comportamento esperado em cenários críticos.[web:8]
- Use testes de widget para validar UI e interação de componentes isolados, sem necessidade de rodar o app inteiro.
- Utilize testes de integração / end-to-end para fluxos completos importantes (login, checkout, cadastro etc.).[web:8]

### 8.2. Cobertura e manutenção

- Busque boa cobertura nos módulos mais críticos (autenticação, pagamento, sincronização de dados), sem perseguir 100% de cobertura a qualquer custo.
- Mantenha os testes claros, com nomes descritivos de cenários e dados de entrada realistas.

### 8.3. Automatização de qualidade

- Configure o projeto para rodar `flutter analyze`, testes e formatador de código em pipelines de CI (GitHub Actions, GitLab CI, etc.).[web:14]
- Utilize ferramentas de métricas de código quando necessário (complexidade ciclomatica, duplicação) para apoiar refatorações.[web:14]

---

## 9. Segurança em apps Flutter

### 9.1. Armazenamento seguro

- Nunca armazene chaves de API sensíveis, tokens ou segredos diretamente no código-fonte.[web:14]
- Use soluções como `flutter_secure_storage` para guardar tokens e credenciais com criptografia, respeitando as práticas de cada plataforma.[web:14]

### 9.2. Comunicação segura

- Use sempre HTTPS/TLS para comunicação com servidores.
- Valide certificados quando necessário e evite aceitar certificados inválidos em produção.

### 9.3. Boas práticas gerais de segurança

- Evite logar dados sensíveis em *logs* de depuração.
- Tenha cuidado com injeção de código ao consumir entradas do usuário e dados de fontes externas.

---

## 10. Publicação, CI/CD e manutenção

### 10.1. Versionamento e empacotamento

- Use versionamento semântico (semver) para comunicar mudanças de forma clara (bugfix, novas features, *breaking changes*).[web:14]
- Mantenha arquivos de configuração de build (Android e iOS) organizados e documentados, com *flavors* ou *targets* bem definidos.

### 10.2. Automação de builds

- Configure pipelines de CI/CD para builds automatizados, execução de testes e distribuição (TestFlight, Play Store Internal Testing etc.).[web:14]
- Automatize também tarefas de *linting*, análise estática e geração de artefatos (APKs, AABs, IPA).

### 10.3. Monitoramento em produção

- Use ferramentas de monitoramento de erros (Crashlytics, Sentry, etc.) para capturar exceções e falhas em tempo real.[web:14]
- Colete métricas de uso e performance de forma anônima para orientar melhorias futuras.

---

## 11. Documentação e colaboração

### 11.1. Documentação de arquitetura

- Mantenha um documento simples descrevendo a arquitetura adotada (camadas, padrões de estado, bibliotecas principais) e os motivos das escolhas.[web:11]
- Documente também a estrutura de pastas, convenções de nomenclatura e padrões visuais importantes.[web:11]

### 11.2. Comentários e docstrings

- Use comentários apenas quando o código não for autoexplicativo; prefira nomes claros de classes, métodos e variáveis.
- Para APIs públicas (widgets reutilizáveis, classes de domínio), use comentários de documentação (`///`) em Dart, facilitando geração de docs e entendimento do time.[web:1]

### 11.3. Fluxo de code review

- Estabeleça um processo de *pull requests* com revisões focadas em legibilidade, simplicidade, testes e aderência às convenções de estilo.[web:11][web:14]
- Mantenha *commits* pequenos e bem descritos, facilitando análise e *debug* futuro.

---

## 12. Checklist rápido de boas práticas

Use esta lista como revisão antes de subir código para o repositório principal:

1. Código formatado com `dart format`/formatador da IDE.[web:10]
2. `flutter analyze` sem erros ou warnings críticos.[web:10]
3. Uso consistente de `final` e `const` para reduzir mutabilidade e reconstruções desnecessárias.[web:4][web:6]
4. Estrutura de pastas coerente por camadas e/ou features.[web:8]
5. Gerência de estado padronizada (Provider/Riverpod/BLoC ou outra bem definida) e documentada.[web:3][web:6]
6. Widgets divididos em componentes reutilizáveis, evitando árvores muito profundas.[web:3][web:6]
7. Listas longas usando `ListView.builder`/`GridView.builder` e *lazy loading* de dados e imagens.[web:5][web:15]
8. Operações pesadas movidas para isolates ou processos assíncronos (`async`/`await`, `compute`).[web:6][web:15]
9. Chamadas de rede com tratamento robusto de erros, cache adequado e payloads otimizados.[web:3][web:8]
10. Testes unitários e de widget para regras de negócio e componentes críticos.[web:8]
11. Nenhum segredo sensível no código; uso de armazenamento seguro para tokens.[web:14]
12. Pipeline de CI configurado com testes, lint e builds automatizados.[web:14]
13. Ferramentas de monitoramento de erros e performance ativas em produção.[web:12][web:14]
14. Documentação básica atualizada (README, arquitetura, convenções de código).[web:1][web:11]

Seguindo estas boas práticas, seus projetos em Flutter/Dart tendem a ser mais organizados, robustos, escaláveis e fáceis de manter ao longo do tempo.[web:1][web:3][web:5][web:8]