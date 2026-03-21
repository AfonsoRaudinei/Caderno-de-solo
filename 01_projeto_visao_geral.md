# 🌱 App Análise de Solo — Visão Geral do Projeto

> Plataforma técnica para análise e recomendação de fertilidade de solo.  
> Stack: **Flutter / Dart** — Estilo visual **iOS/Apple** — Backend: **Firebase ou REST API**

---

## 🎯 Objetivo do App

Permitir que agrônomos e produtores realizem análises de solo, configurem calibrações por nutriente e recebam recomendações técnicas com referências científicas citadas (estilo Perplexity).

---

## 🗺️ Mapa de Páginas

```
App
├── AUTH (fora do nav)
│   ├── Login
│   ├── Cadastro
│   └── Recuperar Senha
│
└── MAIN (Bottom Navigation Bar — 4 tabs)
    ├── 🔬 Análise          → Formulário de análise de solo
    ├── ⚗️  Lab              → TabBar interna
    │   ├── Calibração      → Define referências por nutriente
    │   └── Recomendação    → Resultado com fontes citadas
    ├── 📋 Histórico        → Análises e recomendações anteriores
    └── ⚙️  Config
        ├── Perfil / Dados do usuário
        ├── Base de Dados   → Fórmulas e referências técnicas
        └── Feedback
```

---

## 🔗 Relação Calibração ↔ Recomendação

- Ficam na **mesma tab "Lab"** com TabBar interna no topo
- Navegação por **swipe horizontal** — instantânea, sem re-render
- Calibração define os parâmetros → Recomendação lê em tempo real via **Riverpod**
- Alteração na calibração **atualiza a recomendação automaticamente**

---

## 📱 Navegação

| Tipo | Solução | Motivo |
|---|---|---|
| Bottom Nav | `NavigationBar` (Material 3) | Estilo iOS Tab Bar |
| Rotas | `go_router` | Declarativo, deep link, auth guard |
| Tab interna (Lab) | `TabBar` + `TabBarView` | Swipe entre Calibração e Recomendação |
| Modais | `showModalBottomSheet` | CRUD inline sem nova rota |

---

## 🎨 Design System

- **Filosofia:** iOS/Apple — minimalismo, clareza, dados em destaque
- **Paleta:** Azul `#007AFF`, Branco `#FFFFFF`, Cinza `#F5F5F7`
- **Fonte:** `-apple-system` → `SF Pro` no iOS, `Roboto` fallback Android
- **Widgets:** Preferência por `Cupertino` onde possível
- **Animações:** `flutter_animate` — transições suaves 200ms

---

## 🏗️ Arquitetura

**Clean Architecture** em 3 camadas:

```
lib/
├── core/
├── data/
├── domain/
└── presentation/
```

> Detalhes completos em: `02_arquitetura.md`

---

## 📦 Stack de Dependências

> Detalhes completos em: `03_dependencias.md`

---

## 🧪 CRUD — Regra Geral

Todas as entidades do app suportam:
- ✅ Adicionar
- ✅ Editar
- ✅ Excluir
- ✅ Listar

Entidades: Calibração, Análise de Solo, Base de Dados, Usuário, Feedback

---

*Versão 1.0 — Projeto inicial*
