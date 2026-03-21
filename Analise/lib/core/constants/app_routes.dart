/// Nomes das rotas do SoloForte — go_router
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String recuperarSenha = '/recuperar-senha';

  static const String home = '/'; // Raiz redireciona
  static const String analise = '/analise';
  static const String analiseForm = '/analise/nova';
  static const String analiseDetail =
      '/analise/detalhe'; // + /:id via go_router
  static const String lab = '/lab';
  static const String historico = '/historico';
  static const String culturas = '/culturas';
  static const String config = '/config';

  static const String baseDados = '/config/base-dados';
  static const String baseDadosLegacyAlias = '/home/config/base-dados';
  static const String baseDadosForm = '/config/base-dados/nova';
  static const String baseDadosDetalhe = '/config/base-dados/detalhe';
  static const String perfil = '/config/perfil';
  static const String feedback = '/config/feedback';
}
