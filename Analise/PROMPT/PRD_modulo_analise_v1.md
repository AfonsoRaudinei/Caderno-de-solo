# PRD — Módulo Análise: Ativação Completa
**Produto:** Caderno de Solo  
**Versão:** 1.1  
**Data:** Abril 2026  
**Autor:** Engenharia  
**Status:** Em execução

---

## Visão Geral

O módulo Análise possui infraestrutura sólida (Firestore ativo, GPS real, auth correto,
regras de segurança implementadas). Este documento define os 10 itens necessários para
atingir 100% de funcionamento em produção, com critérios de aceitação mensuráveis
e testes de verificação ao final de cada entrega.

---

## Métricas de Sucesso

| Métrica | Hoje | Meta |
|---------|------|------|
| Itens funcionando em produção | 14/25 | 25/25 |
| Bloqueadores críticos | 3 | 0 |
| Cobertura de testes Firestore | 0% | ≥ 80% |
| Ações stub no detail screen | 3 | 0 |
| Campos filtráveis na busca | 2 | 4 |

---

## Itens de Entrega

---

### ITEM 1 — B1: Edição via `pathParameters`
**Prioridade:** P0 · **Severidade:** 🔴 Bloqueador

#### Problema
Rota `/analise/detalhe/:id/editar` usa `state.extra` para passar `AnaliseSolo`.
`extra` não sobrevive a hot restart, deep link ou rebuild de estado do GoRouter.
Se `extra == null` → formulário abre em modo criação silenciosamente.

#### Solução
Router lê `pathParameters['id']`, busca `AnaliseSolo` no `analiseNotifierProvider`
via `ProviderScope.containerOf`, e passa ao constructor. Se não encontrar → redireciona
para `/analise` via `addPostFrameCallback`.

#### Arquivos
- `app_router.dart` — builder da rota `/editar`
- `analise_detail_screen.dart` — remover `extra: analise` do `context.push`

#### Critérios de Aceitação
- [ ] Editar uma análise → formulário abre com todos os campos preenchidos
- [ ] Hot restart durante edição → ao retornar, formulário ainda abre corretamente
- [ ] ID inexistente na URL → redireciona para `/analise` sem crash
- [ ] `extra` não aparece mais na rota de edição
- [ ] `flutter analyze` sem erros novos

#### Testes de Verificação

**Manual (device):**
1. Abrir detalhe de uma análise existente
2. Tocar em "Editar"
3. Verificar que todos os campos estão preenchidos com os dados da análise
4. Realizar hot restart (`r` no terminal)
5. Tocar em "Editar" novamente — formulário deve abrir preenchido
6. No browser/terminal, navegar para `/analise/detalhe/ID_INVALIDO/editar`
7. Verificar redirecionamento para lista de análises sem crash

**Automatizado:**
```dart
// test/features/analise/router/edicao_route_test.dart
test('editar com ID válido abre NovaAnaliseScreen preenchida', () async {
  final container = createContainer();
  // pre-popular o provider com uma análise mock
  // navegar para /analise/detalhe/:id/editar
  // verificar que NovaAnaliseScreen recebe analiseParaEditar != null
});

test('editar com ID inválido redireciona para /analise', () async {
  // navegar para /analise/detalhe/ID_INEXISTENTE/editar
  // verificar que router redireciona para AppRoutes.analise
});
```

---

### ITEM 2 — I1: Ação "Recomendar" funcional
**Prioridade:** P0 · **Severidade:** 🟡 Incompleto

#### Problema
Botão "Recomendar" no `AnaliseDetailScreen` exibe apenas `SnackBar('Navega para o Lab...')`.
Não navega de fato nem pré-carrega a análise no módulo Lab.

#### Solução
Navegar para `AppRoutes.labRecomendacao` passando o `id` da análise via
`context.push` com `extra: analise.id` (aceitável aqui pois é string simples,
não objeto complexo). O `RecomendacaoPage` deve ler esse ID e carregar a análise.

#### Arquivos
- `analise_detail_screen.dart` — substituir SnackBar por navegação real
- `app_router.dart` — verificar se rota de recomendação aceita parâmetro
- `recomendacao_page.dart` — ler ID da análise e pré-carregar dados

#### Critérios de Aceitação
- [ ] Tocar "Recomendar" → navega para aba Lab > Recomendação
- [ ] Recomendação exibe dados da análise selecionada (não tela em branco)
- [ ] Botão voltar retorna ao detalhe da análise
- [ ] SnackBar "Navega para o Lab..." removido

#### Testes de Verificação

**Manual (device):**
1. Abrir detalhe de análise com dados completos
2. Tocar "Recomendar"
3. Verificar que tela de Recomendação abre com dados da análise
4. Verificar que dados de pH, V%, macronutrientes estão presentes
5. Tocar voltar → retorna ao detalhe

**Automatizado:**
```dart
test('botão Recomendar navega para recomendacao com ID correto', () async {
  // renderizar AnaliseDetailScreen com análise mock
  // tocar no botão Recomendar
  // verificar que context.push foi chamado com AppRoutes.labRecomendacao
  // verificar que extra contém o ID correto
});
```

---

### ITEM 3 — B2: `getProdutores()` real
**Prioridade:** P0 · **Severidade:** 🔴 Bloqueador

#### Problema
`AnaliseFirestoreDatasource.getProdutores()` retorna `const []`.
Seção "Produtores" na `AnaliseListScreen` nunca exibe dados reais em produção.

#### Solução
Agregar produtores distintos a partir das análises do usuário já carregadas:
```dart
Future<List<String>> getProdutores() async {
  final analises = await getAnalises();
  return analises
      .map((a) => a.produtor)
      .where((p) => p.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}
```
Alternativa: criar subcoleção `users/{uid}/produtores` no Firestore para
produtores cadastrados independentemente de análises.

#### Arquivos
- `analise_firestore_datasource.dart` — implementar `getProdutores()`
- `analise_local_datasource.dart` — manter paridade (mock também deve retornar lista)

#### Critérios de Aceitação
- [ ] Seção "Produtores" exibe nomes reais das análises cadastradas
- [ ] Produtores em ordem alfabética
- [ ] Produtor vazio (`''`) não aparece na lista
- [ ] Lista atualiza após nova análise ser salva
- [ ] Mock datasource também retorna lista correta (paridade)

#### Testes de Verificação

**Manual (device):**
1. Cadastrar 2 análises com produtores diferentes
2. Acessar `AnaliseListScreen`
3. Verificar que seção "Produtores" lista os 2 produtores
4. Cadastrar 3ª análise com produtor já existente
5. Verificar que produtor não aparece duplicado

**Automatizado:**
```dart
test('getProdutores retorna lista única e ordenada', () async {
  // mock Firestore com 3 análises: produtor A, B, A
  // chamar getProdutores()
  // expect: ['A', 'B'] — sem duplicata, ordenado
});

test('getProdutores ignora produtor vazio', () async {
  // mock com análise sem produtor (produtor = '')
  // expect: lista sem string vazia
});
```

---

### ITEM 4 — I3: Busca com campos corretos
**Prioridade:** P1 · **Severidade:** 🟡 Incompleto

#### Problema
`analisesFiltradasProvider` filtra apenas `talhao` e `laboratorio`.
Hint text promete "área, produtor, cultura..." — UX incongruente.

#### Solução
Opção A (recomendada): adicionar `produtor` e `fazenda` nos campos de busca.
Opção B: ajustar hint text para refletir os campos realmente filtrados.
Implementar Opção A — corrigir o problema, não o sintoma.

```dart
// analise_provider.dart
if (busca != null && busca.isNotEmpty) {
  final q = busca.toLowerCase();
  return a.talhao.toLowerCase().contains(q) ||
         a.laboratorio.toLowerCase().contains(q) ||
         a.produtor.toLowerCase().contains(q) ||    // novo
         a.fazenda.toLowerCase().contains(q);        // novo
}
```

#### Arquivos
- `analise_provider.dart` — `analisesFiltradasProvider`

#### Critérios de Aceitação
- [ ] Buscar pelo nome do produtor → retorna análises do produtor
- [ ] Buscar pelo nome da fazenda → retorna análises da fazenda
- [ ] Buscar por talhão → mantém funcionamento atual
- [ ] Buscar por laboratorio → mantém funcionamento atual
- [ ] Hint text corresponde aos campos realmente filtrados
- [ ] Busca case-insensitive em todos os campos

#### Testes de Verificação

**Manual (device):**
1. Cadastrar análise com produtor "João Silva"
2. No campo busca, digitar "joão"
3. Verificar que análise aparece no resultado
4. Limpar busca, digitar nome da fazenda
5. Verificar que análise aparece

**Automatizado:**
```dart
test('filtra por produtor', () {
  final analises = [AnaliseSolo(produtor: 'João Silva', ...)];
  final resultado = filtrar(analises, busca: 'joão');
  expect(resultado.length, 1);
});

test('filtra por fazenda', () { ... });
test('busca vazia retorna todos', () { ... });
test('busca sem match retorna lista vazia', () { ... });
```

---

### ITEM 5 — I4: Filtro de safra na UI
**Prioridade:** P1 · **Severidade:** 🟡 Incompleto

#### Problema
`analisesFiltradasProvider` possui `_selectedSafra` mas `AnaliseListScreen`
não tem nenhum widget para o usuário selecionar a safra.
Filtro existe no código mas é inacessível.

#### Solução
Adicionar `FilterChipsWidget` de safra abaixo dos chips de cultura,
populado com as safras distintas das análises carregadas.
Safra selecionada → filtra a lista. Toque novamente → deseleciona.

#### Arquivos
- `analise_list_screen.dart` — adicionar widget de chips de safra
- `analise_provider.dart` — expor `setSafra(String?)` no notifier (se não existir)

#### Critérios de Aceitação
- [ ] Chips de safra visíveis abaixo dos chips de cultura
- [ ] Chips populados com safras reais das análises do usuário
- [ ] Selecionar safra → filtra lista
- [ ] Toque no chip selecionado → deseleciona (mostra todos)
- [ ] Safra e cultura podem ser combinados (filtro AND)
- [ ] Se não há análises com safra definida → chips de safra não aparecem

#### Testes de Verificação

**Manual (device):**
1. Cadastrar análises com safras diferentes (ex: "2024/25", "2025/26")
2. Verificar chips de safra visíveis na lista
3. Selecionar "2024/25" → apenas análises dessa safra aparecem
4. Selecionar chip de cultura → filtra por safra E cultura
5. Tocar "2024/25" novamente → todos aparecem

**Automatizado:**
```dart
test('selecionar safra filtra corretamente', () {
  // provider com análises de 2 safras diferentes
  // setar selectedSafra = '2024/25'
  // expect: apenas análises de 2024/25
});

test('filtro safra + cultura é AND', () { ... });
```

---

### ITEM 6 — I8: Verificar `produtorPadrao` vazio
**Prioridade:** P1 · **Severidade:** 🟡 Incompleto

#### Problema
`nova_analise_screen.dart` chama `ctrl.salvar('')` passando string vazia
como `produtorPadrao`. Comportamento em produção não foi verificado.
Se a validação não bloquear corretamente → análise salva sem produtor.

#### Solução
1. Verificar o que `ctrl.salvar('')` faz com o argumento
2. Se `produtorPadrao` é ignorado quando o campo está preenchido → OK, documentar
3. Se há risco → corrigir passando o valor real do campo de produtor

#### Arquivos
- `nova_analise_screen.dart` — verificar chamada de `_salvar()`
- `nova_analise_controller.dart` — verificar uso de `produtorPadrao`
- `analise_data_contract.dart` — verificar validação de produtor

#### Critérios de Aceitação
- [ ] Salvar análise sem produtor → bloqueado com mensagem de erro clara
- [ ] Salvar análise com produtor preenchido → salva corretamente
- [ ] Campo produtor marcado como obrigatório na UI
- [ ] Comportamento documentado no código com comentário

#### Testes de Verificação

**Manual (device):**
1. Abrir "Nova Análise"
2. Preencher todos os campos exceto produtor
3. Tocar "Salvar" → deve bloquear com erro
4. Preencher produtor e tentar novamente → deve salvar

**Automatizado:**
```dart
test('salvar sem produtor retorna erro de validação', () {
  final contract = AnaliseDataContract();
  final resultado = contract.validar(AnaliseSolo(produtor: '', ...));
  expect(resultado.hasBlockingErrors, true);
  expect(resultado.errors, contains(predicate((e) => e.campo == 'produtor')));
});
```

---

### ITEM 7 — B3: Testes do `AnaliseFirestoreDatasource`
**Prioridade:** P1 · **Severidade:** 🔴 Bloqueador (qualidade)

#### Problema
Zero cobertura de testes no `AnaliseFirestoreDatasource`.
Todo o fluxo real de produção está sem proteção de CI.
Regressões no Firestore não são detectadas antes do release.

#### Solução
Implementar testes de integração usando **Firebase Emulator**:
- `getAnalises()` — retorna lista correta filtrada por `userId`
- `saveAnalisesBatch()` — persiste e é idempotente
- `deleteAnalise()` — remove documento e não afeta outros usuários
- `getProdutores()` — após implementação do Item 3

#### Arquivos
- `test/features/analise/data/analise_firestore_datasource_test.dart` — novo
- `firebase.json` — habilitar emulators se não configurado

#### Critérios de Aceitação
- [ ] Testes rodam com Firebase Emulator (sem rede real)
- [ ] `getAnalises()` retorna apenas análises do userId correto
- [ ] `saveAnalisesBatch()` é idempotente (2 chamadas = mesmo resultado)
- [ ] `deleteAnalise()` remove apenas o documento correto
- [ ] CI passa com `flutter test` após configuração do emulator

#### Testes de Verificação

**Automatizado:**
```dart
// test/features/analise/data/analise_firestore_datasource_test.dart
group('AnaliseFirestoreDatasource', () {
  late AnaliseFirestoreDatasource datasource;
  late FirebaseFirestore fakeFirestore; // firebase_core_platform_interface mock

  setUp(() async {
    // inicializar Firebase Emulator
    fakeFirestore = FakeFirebaseFirestore(); // package: fake_cloud_firestore
    datasource = AnaliseFirestoreDatasource(firestore: fakeFirestore);
  });

  test('getAnalises retorna apenas análises do userId', () async {
    // inserir análises de userId A e userId B
    // chamar getAnalises() como userId A
    // expect: apenas análises de A
  });

  test('saveAnalisesBatch é idempotente', () async {
    // salvar lote com 2 análises
    // salvar mesmo lote novamente
    // expect: Firestore tem apenas 2 documentos (não 4)
  });

  test('deleteAnalise remove documento correto', () async {
    // inserir 2 análises
    // deletar análise 1
    // expect: análise 2 ainda existe, análise 1 não existe
  });
});
```

---

### ITEM 8 — I7: Índice composto no Firestore
**Prioridade:** P2 · **Severidade:** 🟡 Débito técnico

#### Problema
Query de análises usa `.where('userId', isEqualTo: uid)` sem `.orderBy()`.
Sort é feito em memória em Dart. Com volume alto (100+ análises),
a query retorna todos os documentos antes de ordenar — degradação de performance.

#### Solução
1. Adicionar `.orderBy('dataCadastro', descending: true)` na query Firestore
2. Criar índice composto no Firebase Console: `userId ASC` + `dataCadastro DESC`
3. Remover sort em memória após confirmação do índice

#### Arquivos
- `analise_firestore_datasource.dart` — adicionar `.orderBy()`
- Firebase Console — criar índice composto (não é arquivo de código)

#### Critérios de Aceitação
- [ ] Índice composto criado no Firebase Console (status: Ativado)
- [ ] Query usa `.orderBy('dataCadastro', descending: true)`
- [ ] Lista ordenada por data sem sort em memória
- [ ] Performance medida com 50+ análises (tempo de carregamento < 2s)
- [ ] Sem `FirebaseException` de índice ausente nos logs

#### Testes de Verificação

**Manual (Firebase Console):**
1. Acessar Firebase Console → Firestore → Índices
2. Verificar índice `analises: userId ASC + dataCadastro DESC` com status "Ativado"

**Manual (device):**
1. Cadastrar 10+ análises em datas diferentes
2. Abrir lista → verificar ordem cronológica inversa (mais recente primeiro)
3. Abrir Logcat/Console → sem warnings de índice ausente

**Automatizado:**
```dart
test('getAnalises retorna ordenado por dataCadastro decrescente', () async {
  // inserir análises com datas diferentes
  final resultado = await datasource.getAnalises();
  expect(resultado.first.dataCadastro.isAfter(resultado.last.dataCadastro), true);
});
```

---

### ITEM 9 — I2: Stream real-time (decisão de produto)
**Prioridade:** P2 · **Severidade:** 🟡 Incompleto

#### Problema
`AnaliseNotifier.build()` é `AsyncNotifier` com `Future` (one-shot).
Lista só atualiza quando `invalidateSelf()` é chamado manualmente.
Sem sincronização automática entre dispositivos.

#### Decisão necessária
Antes de implementar, definir:
- O app precisa de sincronização em tempo real entre dispositivos?
- O usuário usa múltiplos dispositivos simultaneamente?
- O custo de reads Firestore com `snapshots()` é aceitável?

#### Solução (se aprovado)
Substituir `Future<List<AnaliseSolo>>` por `Stream<List<AnaliseSolo>>`:
```dart
@Riverpod(keepAlive: true)
class AnaliseNotifier extends _$AnaliseNotifier {
  @override
  Stream<List<AnaliseSolo>> build() {
    return ref.read(getAnalisesUsecaseProvider).stream(); // retorna Stream
  }
}
```

#### Arquivos
- `analise_firestore_datasource.dart` — expor `watchAnalises()` retornando `Stream`
- `analise_repository_impl.dart` — repassar stream
- `analise_provider.dart` — `AnaliseNotifier` vira `StreamNotifier`

#### Critérios de Aceitação
- [ ] Análise salva em dispositivo A aparece em dispositivo B sem refresh manual
- [ ] Análise excluída some da lista em tempo real
- [ ] Sem rebuild excessivo (debounce se necessário)
- [ ] Custo de reads Firestore monitorado e aceitável

#### Testes de Verificação

**Manual (2 dispositivos):**
1. Abrir app em dispositivo A e dispositivo B (mesmo usuário)
2. Cadastrar análise no dispositivo A
3. Verificar que aparece no dispositivo B sem ação manual
4. Excluir análise no dispositivo B
5. Verificar que some do dispositivo A

---

### ITEM 10 — I5 + I6: Freezed + Entidade duplicada
**Prioridade:** P2 · **Severidade:** 🟡 Débito técnico

#### Problema
- `AnaliseSolo` é POJO sem `copyWith`, `==`, `hashCode` → rebuilds Riverpod desnecessários
- `analise_entity.dart` (Freezed gerado) coexiste com `analise_solo.dart` (POJO)
- Risco de divergência de schema entre os dois

#### Solução
**Fase 1** — Deprecar `analise_entity.dart`:
- Mapear todos os usos de `AnaliseEntity` no projeto
- Substituir por `AnaliseSolo` progressivamente
- Marcar `analise_entity.dart` como `@Deprecated`

**Fase 2** — Migrar `AnaliseSolo` para Freezed:
```dart
@freezed
class AnaliseSolo with _$AnaliseSolo {
  const factory AnaliseSolo({
    required String id,
    required String produtor,
    // ... todos os campos
  }) = _AnaliseSolo;

  factory AnaliseSolo.fromJson(Map<String, dynamic> json) =>
      _$AnaliseSoloFromJson(json);
}
```

#### Arquivos
- `analise_solo.dart` — migrar para Freezed
- `analise_solo.freezed.dart` — gerado por `build_runner`
- `analise_entity.dart` — marcar `@Deprecated` e depois remover
- Todos os arquivos que usam `AnaliseSolo.copyWith` manual → usar o gerado

#### Critérios de Aceitação
- [ ] `AnaliseSolo` é Freezed com `copyWith`, `==`, `hashCode` gerados
- [ ] `analise_entity.dart` marcado `@Deprecated` ou removido
- [ ] Nenhum uso de `AnaliseEntity` em código de produção
- [ ] `flutter test` passa após migração
- [ ] `flutter analyze` sem erros

#### Testes de Verificação

**Automatizado:**
```dart
test('AnaliseSolo == funciona corretamente', () {
  final a1 = AnaliseSolo(id: '1', produtor: 'João', ...);
  final a2 = AnaliseSolo(id: '1', produtor: 'João', ...);
  expect(a1, equals(a2)); // falha hoje sem Freezed
});

test('AnaliseSolo copyWith preserva campos não alterados', () {
  final original = AnaliseSolo(id: '1', produtor: 'João', ph: 6.0, ...);
  final editado = original.copyWith(ph: 6.5);
  expect(editado.produtor, 'João');
  expect(editado.ph, 6.5);
});
```

---

## Resumo de Entregas

| Item | Descrição | Prioridade | Arquivos | Status |
|------|-----------|------------|---------|--------|
| B1 | Edição via `pathParameters` | P0 🔴 | 2 | ✅ |
| I1 | Ação "Recomendar" funcional | P0 🟡 | 3 | ✅ |
| B2 | `getProdutores()` real | P0 🔴 | 2 | ✅ |
| I3 | Busca com campos corretos | P1 🟡 | 1 | ✅ |
| I4 | Filtro de safra na UI | P1 🟡 | 2 | ✅ |
| I8 | Verificar `produtorPadrao` | P1 🟡 | 2 | ✅ |
| B3 | Testes Firestore Datasource | P1 🔴 | 1 novo | ✅ |
| I7 | Índice composto Firestore | P2 🟡 | 1 + console | ✅ |
| I2 | Stream real-time | P2 🟡 | 3 | ✅ |
| I5+I6 | Freezed + entidade duplicada | P2 🟡 | 4+ | 🔶 |

---

## Definition of Done (global)

Cada item é considerado **DONE** quando:
1. ✅ Todos os critérios de aceitação marcados
2. ✅ Testes manuais passaram no device (iOS real)
3. ✅ Testes automatizados escritos e passando
4. ✅ `flutter analyze` sem erros novos
5. ✅ Código revisado e prompt de auditoria executado
6. ✅ Status atualizado neste documento
