# Agente Feature Clientes

## Escopo

Cadastro e gestão de Cliente → Fazenda → Talhão, detalhe com abas (resumo, análises, recomendações), vínculo hierárquico com análises e tokens/QR.

## Inviolável

- Este módulo é **produto core**. Não remover, esvaziar nem omitir em branches paralelas.
- Rotas em `AppRoutes.clientes*` e aba `Clientes` em `MainPage` são obrigatórias.
- O `tool/product_modules_guard.sh` e `test/core/product_modules_guard_test.dart` devem continuar passando.
- Antes de merge/checkout que toque `lib/features/`, confirme que `lib/features/clientes/` permanece intacto.

## Regras

- UI não fala com Firestore direto; use provider → repository → datasource.
- Telefone/e-mail são opcionais; não bloqueie salvamento por ausência deles.
- Sessão inválida redireciona para login com mensagem clara.
- Não altere dados, textos, campos ou arquivos que não tenham sido citados no prompt.

## Testes indicados

```bash
flutter test test/features/clientes/ test/core/constants/app_routes_cliente_test.dart test/core/product_modules_guard_test.dart test/presentation/clientes/
./tool/product_modules_guard.sh
```

## Conclusao

Use sempre o checklist final obrigatorio do agente mestre.
