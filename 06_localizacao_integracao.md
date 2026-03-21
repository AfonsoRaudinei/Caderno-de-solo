# 🗺️ Localização + Integração entre Apps

> SoloForte (análise de solo) ↔ App Mapa (segundo app Flutter)  
> Referência visual de pin no mapa: estilo SulGoianoApp

---

## 📍 Localização na Análise de Solo

### Campos adicionados ao formulário de Análise

```dart
// Seção: Localização (nova seção no formulário de Análise)

latitude:   double   // -23.550520
longitude:  double   // -46.633308
precisao:   double   // metros (GPS accuracy)
enderecoRural: String  // "Fazenda Boa Vista, Talhão 3" (opcional, manual)
municipio:  String   // preenchido automaticamente via reverse geocoding
estado:     String   // preenchido automaticamente
```

### Captura da localização

```
┌─ Seção: Localização ─────────────────────────┐
│  [📍 Usar localização atual]   ← botão iOS   │
│                                               │
│  Lat: -23.550520   Long: -46.633308          │
│  Precisão: ±5m                                │
│  Município: Ribeirão Preto - SP               │
│                                               │
│  Descrição: [Fazenda / Talhão____]  (manual) │
└───────────────────────────────────────────────┘
```

**Comportamento:**
- Botão "Usar localização atual" → `geolocator` captura lat/long
- Reverse geocoding automático → preenche município e estado
- Campo descrição: manual, livre
- Permissão de localização: solicitada na primeira análise

---

## 🔥 Recomendação: Firebase Firestore

### Por que Firestore para este caso?

| Critério | Firestore | API REST própria |
|---|---|---|
| Tempo de implementação | ✅ Rápido | ❌ Precisa backend |
| Sincronização em tempo real | ✅ Nativo | ❌ Polling ou WebSocket |
| Dois apps lendo o mesmo dado | ✅ Perfeito | ⚠️ Precisa orquestrar |
| Pin no mapa atualiza ao salvar análise | ✅ Automático | ❌ Depende de push |
| Custo inicial | ✅ Gratuito (Spark plan) | ❌ Servidor = custo |
| Escala futura | ✅ Suporta bem | ✅ Controle total |
| Offline (campo sem sinal) | ✅ Nativo | ❌ Implementar manualmente |

**Conclusão:** Firestore agora. API REST própria no futuro quando precisar de lógica de servidor mais complexa (ex: ML para recomendações).

---

## 🏗️ Arquitetura de Integração

```
┌─────────────────────────────────────────────────┐
│                  FIREBASE                        │
│                                                  │
│  Firestore DB:                                   │
│  ├── /usuarios/{uid}                             │
│  ├── /analises/{id}        ← dados + lat/long    │
│  └── /recomendacoes/{id}   ← vinculada à análise │
│                                                  │
│  Firebase Auth:  login compartilhado (opcional)  │
│  Firebase Storage: fotos do campo (futuro)       │
└──────────────┬──────────────────────────────────┘
               │  lê / escreve
       ┌───────┴────────┐
       ▼                ▼
  ┌─────────┐     ┌──────────────┐
  │SoloForte│     │  App Mapa    │
  │(este app)│    │(segundo app) │
  │         │     │              │
  │ Cria    │     │ Lê lat/long  │
  │ análise │     │ Exibe pins   │
  │ + lat/  │     │ no mapa      │
  │   long  │     │ Clique →     │
  └─────────┘     │ expande dados│
                  └──────────────┘
```

---

## 📄 Modelo de Dados — Firestore

### Coleção: `/analises/{id}`

```json
{
  "id": "uuid-gerado",
  "usuarioId": "uid-firebase",
  "criadoEm": "2026-03-10T14:30:00Z",
  "atualizadoEm": "2026-03-10T14:30:00Z",
  "status": "completa",

  "identificacao": {
    "nomeArea": "Fazenda Boa Vista - Talhão 3",
    "cultura": "Soja",
    "dataColeta": "2026-03-10",
    "laboratorio": "LabSolo Análises"
  },

  "localizacao": {
    "latitude": -21.780148,
    "longitude": -47.321055,
    "precisao": 5.0,
    "municipio": "Ribeirão Preto",
    "estado": "SP",
    "descricao": "Talhão 3 - área norte"
  },

  "dadosFisicos": {
    "argila": 45,
    "profundidade": "0-20cm"
  },

  "ph": {
    "agua": 5.8,
    "smp": 6.2,
    "cacl2": 5.5
  },

  "macronutrientes": {
    "fosforo": 18.0,
    "potassio": 2.8,
    "calcio": 32.0,
    "magnesio": 12.0,
    "enxofre": 8.0
  },

  "acidez": {
    "aluminio": 0.0,
    "hMaisAl": 45.0,
    "ctc": 92.0,
    "saturacaoBases": 50.2
  },

  "micronutrientes": {
    "boro": 0.35,
    "cobre": 1.8,
    "ferro": 42.0,
    "manganes": 15.0,
    "zinco": 1.2
  },

  "recomendacaoId": "uuid-recomendacao"
}
```

### Coleção: `/recomendacoes/{id}`

```json
{
  "id": "uuid-recomendacao",
  "analiseId": "uuid-analise",
  "usuarioId": "uid-firebase",
  "calibracaoId": "uuid-calibracao-usada",
  "criadoEm": "2026-03-10T14:30:00Z",

  "localizacao": {
    "latitude": -21.780148,
    "longitude": -47.321055
  },

  "resultados": {
    "calcario": { "necessidade": 2.5, "unidade": "t/ha", "metodo": "SMP" },
    "gesso":    { "necessidade": 800, "unidade": "kg/ha" },
    "fosforo":  { "necessidade": 120, "unidade": "kg P₂O₅/ha" },
    "potassio": { "necessidade": 80,  "unidade": "kg K₂O/ha" },
    "enxofre":  { "necessidade": 0,   "unidade": "kg/ha", "status": "adequado" }
  },

  "referencias": [
    { "indice": 1, "titulo": "Boletim 100 IAC", "ano": 1997 },
    { "indice": 2, "titulo": "Embrapa Cerrados", "ano": 2004 }
  ]
}
```

---

## 🗺️ O que o App Mapa recebe

O segundo app lê a coleção `/analises` filtrando por `usuarioId` e exibe:

### Pin no mapa
```
Marcador: lat/long da análise
Cor do pin: baseada no status do solo
  🟢 Verde  → V% acima do ideal
  🟡 Amarelo → V% próximo do limite
  🔴 Vermelho → V% abaixo — necessita correção
```

### Ao clicar no pin — card expandido
```
┌─────────────────────────────────────┐
│ 📍 Fazenda Boa Vista - Talhão 3     │
│ Soja · 10/03/2026                   │
├─────────────────────────────────────┤
│ pH: 5.8     V%: 50.2%               │
│ P: 18 mg    K: 2.8 mmol             │
├─────────────────────────────────────┤
│ Recomendação:                       │
│ Calcário: 2,5 t/ha                  │
│ Gesso: 800 kg/ha                    │
├─────────────────────────────────────┤
│         [Ver análise completa →]    │
└─────────────────────────────────────┘
```

---

## 📦 Packages adicionais necessários

```yaml
# No pubspec.yaml — adicionar:

# Localização
geolocator: ^11.0.0           # GPS lat/long
geocoding: ^3.0.0             # Reverse geocoding → município/estado

# Firebase
firebase_core: ^2.27.0
cloud_firestore: ^4.17.0
firebase_auth: ^4.20.0

# Mapa (no App Mapa — segundo app)
google_maps_flutter: ^2.7.0   # ou flutter_map (OpenStreetMap, gratuito)
```

> **Dica:** `flutter_map` + OpenStreetMap = sem custo de API key. `google_maps_flutter` = mais polido visualmente. Decidir conforme orçamento.

---

## 🔒 Segurança Firestore — Regras básicas

```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Análises: só o dono acessa
    match /analises/{analiseId} {
      allow read, write: if request.auth.uid == resource.data.usuarioId;
    }

    // Recomendações: só o dono acessa
    match /recomendacoes/{recId} {
      allow read, write: if request.auth.uid == resource.data.usuarioId;
    }
  }
}
```

---

## 🔮 Preparado para API REST futura

A arquitetura Firestore **não atrapalha** uma migração futura. Quando quiser adicionar API REST própria:

1. Criar camada `RemoteDataSource` em `/data/datasources/remote/`
2. Manter interface do `Repository` igual — UI não muda nada
3. Migrar datasource de Firestore → HTTP gradualmente

> Clean Architecture garante isso — a UI nunca sabe de onde vêm os dados.

---

*Versão 1.1 — Localização + Integração entre apps adicionadas*
