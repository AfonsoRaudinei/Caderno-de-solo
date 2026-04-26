/// Redireciona a rota /analise para o módulo completo (Clean Architecture)
/// O router ainda usa `AnalisePage` como nome de classe — aqui usamos
/// `AnaliseListScreen` diretamente como `AnalisePage` via typedef.
library;

import 'package:soloforte/features/analise/presentation/screens/analise_list_screen.dart';

/// Alias para manter compatibilidade com o router existente
typedef AnalisePage = AnaliseListScreen;
