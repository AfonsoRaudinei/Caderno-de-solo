# 🔥 Firebase — Configuração App Mapa (Segundo App)

> Este documento é para o **segundo app Flutter** (App Mapa com pins).  
> Ele lê os dados do **mesmo projeto Firebase** do SoloForte.  
> Nenhum dado novo é criado aqui — apenas leitura.

---

## ⚠️ Pré-requisito

O projeto Firebase já deve estar criado pelo SoloForte.  
O App Mapa entra como **segundo app** no mesmo projeto Firebase.

---

## 📱 Registrar o App Mapa no Firebase

### Passo 1 — Acessar o Console Firebase

```
https://console.firebase.google.com
→ Selecionar o projeto do SoloForte
→ Visão geral do projeto (ícone ⚙️)
→ "Adicionar app"
```

### Passo 2 — Registrar Android

```
→ Escolher ícone Android
→ Package name: com.seudominio.appmapa
→ Apelido: App Mapa
→ Baixar: google-services.json
→ Colocar em: android/app/google-services.json
```

### Passo 3 — Registrar iOS

```
→ Escolher ícone Apple
→ Bundle ID: com.seudominio.appmapa
→ Apelido: App Mapa iOS
→ Baixar: GoogleService-Info.plist
→ Colocar em: ios/Runner/GoogleService-Info.plist
```

---

## 📦 pubspec.yaml — App Mapa

```yaml
name: app_mapa
description: Mapa de análises de solo com pins georreferenciados.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # ─── FIREBASE (mesmo projeto do SoloForte) ───────────────
  firebase_core: ^2.27.0
  cloud_firestore: ^4.17.0      # Lê análises e recomendações
  firebase_auth: ^4.20.0        # Mesma autenticação do SoloForte

  # ─── MAPA ────────────────────────────────────────────────
  flutter_map: ^6.1.0           # OpenStreetMap — sem custo de API key
  latlong2: ^0.9.0              # Coordenadas lat/long para flutter_map

  # ─── NAVEGAÇÃO ───────────────────────────────────────────
  go_router: ^13.0.0

  # ─── ESTADO ──────────────────────────────────────────────
  flutter_riverpod: ^2.5.0

  # ─── UI ──────────────────────────────────────────────────
  cupertino_icons: ^1.0.8
  flutter_animate: ^4.5.0

  # ─── UTILITÁRIOS ─────────────────────────────────────────
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

> **Por que `flutter_map` e não `google_maps_flutter`?**  
> `flutter_map` usa OpenStreetMap — gratuito, sem API key, sem cobrança por uso.  
> `google_maps_flutter` cobra após 28.000 requisições/mês.  
> Para uso agrícola (áreas rurais) o OpenStreetMap tem cobertura suficiente.

---

## 🏗️ Estrutura de Pastas — App Mapa

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Mesma paleta iOS do SoloForte
│   │   └── app_theme.dart
│   └── constants/
│       └── firestore_keys.dart   # Nomes das coleções (compartilhado)
│
├── data/
│   ├── models/
│   │   ├── analise_mapa_model.dart      # Subconjunto do modelo do SoloForte
│   │   └── recomendacao_mapa_model.dart
│   └── repositories/
│       └── analise_mapa_repository.dart
│
└── presentation/
    ├── auth/
    │   └── login_page.dart       # Mesma conta — redireciona ao SoloForte
    └── mapa/
        ├── mapa_page.dart        # Tela principal com flutter_map
        ├── mapa_controller.dart  # Riverpod — stream do Firestore
        └── widgets/
            ├── pin_marker.dart         # Pin colorido no mapa
            └── analise_bottom_sheet.dart  # Card expandido ao clicar no pin
```

---

## 🔄 Leitura do Firestore — Stream em tempo real

```dart
// data/repositories/analise_mapa_repository.dart

class AnaliseMaPaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream — atualiza o mapa automaticamente ao salvar nova análise no SoloForte
  Stream<List<AnaliseMapa>> streamAnalisesPorUsuario(String usuarioId) {
    return _db
        .collection('analises')
        .where('usuarioId', isEqualTo: usuarioId)
        .where('status', isEqualTo: 'completa')
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AnaliseMapa.fromFirestore(doc))
            .toList());
  }
}
```

**Resultado:** quando o agrônomo salva uma análise no SoloForte, o pin aparece no App Mapa **automaticamente**, sem precisar recarregar.

---

## 📍 Modelo reduzido — o que o App Mapa lê

O App Mapa **não precisa de todos os campos** da análise. Lê apenas:

```dart
// data/models/analise_mapa_model.dart

class AnaliseMapa {
  final String id;
  final double latitude;
  final double longitude;
  final String nomeArea;
  final String cultura;
  final DateTime dataColeta;
  final double saturacaoBases;    // V% → define cor do pin
  final double ph;
  final String recomendacaoId;   // Para buscar recomendação ao expandir

  // Cor do pin baseada no V%
  Color get corPin {
    if (saturacaoBases >= 60) return Color(0xFF34C759);  // 🟢 Verde — ideal
    if (saturacaoBases >= 40) return Color(0xFFFFCC00);  // 🟡 Amarelo — atenção
    return Color(0xFFFF3B30);                             // 🔴 Vermelho — corrigir
  }
}
```

---

## 🗺️ Tela do Mapa — Layout

```
┌─────────────────────────────────────┐
│  🔍 [Buscar área...]                │  ← SearchBar no topo
├─────────────────────────────────────┤
│                                     │
│         [MAPA OPENSTREETMAP]        │
│                                     │
│    🟢      🔴                       │  ← Pins coloridos
│         🟡                          │
│                                     │
│                      🟢             │
│                                     │
└─────────────────────────────────────┘
│ Legenda: 🟢 Ideal  🟡 Atenção  🔴 Corrigir │
```

**Ao clicar no pin → BottomSheet sobe:**

```
┌─────────────────────────────────────┐
│ ━━━━━  (handle)                     │
│                                     │
│ 📍 Fazenda Boa Vista — Talhão 3     │
│ Soja · 10/03/2026                   │
│                                     │
│ pH: 5.8          V%: 50.2%          │
│ P: 18 mg/dm³     K: 2.8 mmol       │
│                                     │
│ ── Recomendação ──────────────────  │
│ Calcário:  2,5 t/ha                 │
│ Gesso:     800 kg/ha                │
│ Fósforo:   120 kg P₂O₅/ha          │
│                                     │
│  [Ver análise completa no SoloForte]│
└─────────────────────────────────────┘
```

---

## 🔑 Autenticação Compartilhada

O usuário faz login **uma vez** — a conta é a mesma nos dois apps:

```dart
// Verificar se já está logado ao abrir o App Mapa
FirebaseAuth.instance.authStateChanges().listen((user) {
  if (user != null) {
    // Já logado → ir direto para o mapa
    context.go('/mapa');
  } else {
    // Não logado → tela de login
    context.go('/login');
  }
});
```

---

## 🔒 Regras Firestore — sem alteração

O App Mapa só lê. As regras já definidas no SoloForte cobrem isso:

```
// Já configurado no SoloForte — nenhuma mudança necessária
allow read: if request.auth.uid == resource.data.usuarioId;
```

---

## ✅ Checklist de configuração

```
[ ] Projeto Flutter criado no IDX
[ ] App registrado no Firebase Console (Android + iOS)
[ ] google-services.json → android/app/
[ ] GoogleService-Info.plist → ios/Runner/
[ ] pubspec.yaml configurado (copiar deste doc)
[ ] flutter pub get
[ ] firebase_options.dart gerado via FlutterFire CLI:
    → dart pub global activate flutterfire_cli
    → flutterfire configure
[ ] Testar stream do Firestore com análise criada no SoloForte
[ ] Verificar pins aparecendo no mapa
```

---

*Versão 1.0 — App Mapa — leitura do Firestore do SoloForte*
