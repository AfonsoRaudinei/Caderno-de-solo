# 05 — Firebase & Firestore (SoloForte + App Mapa)

> **Status:** 🔄 Reactiva o stack Firebase completo (Auth + coleções) mas a UI de análises ainda usa mocks; o segundo app (App Mapa) já referencia este mesmo projeto Firestore.

## Inicialização (main + firebase_options)

- `main.dart` chama `WidgetsFlutterBinding.ensureInitialized()`, registra `Hive.initFlutter()`, e invoca `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.  
- `firebase_options.dart` foi gerado com placeholders para Android/web/macos e valores reais para iOS (`projectId: soloforte-106c8`). Reexecute `flutterfire configure` sempre que alterar o projeto Firebase ou criar apps adicionais.  
- `ProviderScope` + `MaterialApp.router` só são instanciados após a inicialização do Firebase.

## Auth (FirebaseAuth + FlutterSecureStorage)

- `AuthDatasource` encapsula `FirebaseAuth` para login, cadastro, reset de senha e logout.  
- Após login/cadastro, o UID do usuário é gravado em `FlutterSecureStorage` (chave `auth_token`) para suportar redirecionamentos em `routerProvider`.  
- `LoginController`, `CadastroController` e `RecuperarSenhaController` expõem estados (idle/loading/error) via Riverpod. O feedback de erro (e-mail inválido, senha curta, e-mail em uso) já passa pela camada de datasource.

## Estrutura de coleções Firestore

| Coleção | Descrição | Operações implementadas |
| --- | --- | --- |
| `analises` | Armazena documentos com todos os campos de `AnaliseModel` (pH, macronutrientes, localização, datas, IDs). | `addAnalise`, `updateAnalise`, `deleteAnalise`, `getAnalise`, `getAnalisesByUser` em `AnaliseFirestoreDatasource`. Essas operações ainda não substituem o mock local (`AnaliseLocalDatasource`). |
| `recomendacoes` | Documentos `RecomendacaoModel` ligados a `analiseId`. | `saveRecomendacao`, `getRecomendacoesByAnalise`. Ideal para alimentar o módulo Laboratório e o App Mapa ao carregar recomendações já salvas. |
| `users/{uid}/calibracoes` | Perfis de calibração do usuário (usados pela tela de Calibração). | `CalibracaoFirestoreDatasource` faz `getProfiles`, `upsertProfile` e `deleteProfile`. Os dados também são sincronizados com `Hive` para cache offline. |

> Use `timestamp` servidor (`FieldValue.serverTimestamp()`) nos datasources para manter `createdAt/updatedAt` consistentes.

## Segurança & regras recomendadas

- Regra mínima:  
  ```js
  match /{document=**} {
    allow read, write: if request.auth != null && request.auth.uid == resource.data.usuarioId;
  }
  ```  
  Ajuste conforme coleções públicas (ex.: `referenciasTecnicas`).  
- Não há arquivo `firestore.rules` neste repo; adicione na raiz quando definir regras em produção.  
- As regras acima cobrem o App Mapa (leitura) e SoloForte (leitura/escrita). Todos os acessos passam por `FirebaseAuth`, portanto o App Mapa herda automaticamente a mesma segurança.

## Integração do segundo app (App Mapa)

- O **mesmo projeto Firebase** hospeda o App Mapa (veja `07_app_mapa_firebase.md`).  
- O App Mapa registra Android/iOS com bundle IDs próprios e baixa `google-services.json` e `GoogleService-Info.plist` dentro do seu workspace.  
- Para ler dados em tempo real ele usa um stream parecido com:  
  ```dart
  FirebaseFirestore.instance
    .collection('analises')
    .where('usuarioId', isEqualTo: usuarioId)
    .where('status', isEqualTo: 'completa')
    .orderBy('criadoEm', descending: true)
    .snapshots();
  ```
- `FirebaseAuth` é compartilhado: o mesmo login do SoloForte serve para o mapa.  
- O App Mapa usa `flutter_map` + `latlong2` (sem custos com API key) e cores baseadas em V% para pintar pins.

## Operações sugeridas antes do deploy

1. Execute `dart pub global activate flutterfire_cli` e rode `flutterfire configure` sempre que fizer alterações significativas nas chaves.  
2. Ajuste `firebase_options.dart` com as credenciais reais de Android/web/macos (hoje são placeholders).  
3. Garanta que `AnaliseFirestoreDatasource` seja conectado ao repositório principal quando o backend estiver pronto (substituir `AnaliseLocalDatasource`).  
4. Documente o `OAuth redirect`/API key no console Firebase e mantenha as credenciais sensíveis nos secrets do Codemagic ou GitHub Actions.
