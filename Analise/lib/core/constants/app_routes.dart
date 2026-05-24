/// Nomes das rotas do SoloForte — go_router
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String recuperarSenha = '/recuperar-senha';
  static const String verificarEmail = '/verificar-email';
  static const String authBootstrap = '/auth-bootstrap';

  static const String home = '/'; // Raiz redireciona
  static const String analise = '/analise';
  static const String analiseForm = '/analise/nova';
  static const String analiseDetail =
      '/analise/detalhe'; // + /:id via go_router
  static const String lab = '/lab';
  static const String labCalibracao = '/lab/calibracao';
  static const String labCalibracaoEditar = '/lab/calibracao/editar';
  static const String labRecomendacao = '/lab/recomendacao';
  static const String labReferencias = '/lab/referencias';
  static const String labRefTecnicas = '/lab/referencias/tecnicas';
  static const String labRefDetalhes = '/lab/referencias/detalhes';
  static const String labRefNova = '/lab/referencias/nova';
  static const String labRefMetricas = '/lab/referencias/metricas';
  static const String labRefAbsorcaoNutrientes =
      '/lab/referencias/absorcao-nutrientes';
  static const String labHistorico = '/lab/historico';
  static const String mapa = '/mapa';
  static const String historico = '/historico';
  static const String culturas = '/culturas';
  static const String config = '/config';

  @Deprecated('Use AppRoutes.labRefTecnicas')
  static const String baseDados = '/config/base-dados';
  @Deprecated('Use AppRoutes.labRefTecnicas')
  static const String baseDadosLegacyAlias = '/home/config/base-dados';
  @Deprecated('Use AppRoutes.labRefNova')
  static const String baseDadosForm = '/config/base-dados/nova';
  @Deprecated('Use AppRoutes.labRefDetalhes')
  static const String baseDadosDetalhe = '/config/base-dados/detalhe';
  static const String perfil = '/config/perfil';
  static const String feedback = '/config/feedback';
  static const String configLabTemplates = '/config/lab-templates';
  static const String configLabTemplateEdit = '/config/lab-templates/editar';
  @Deprecated('Use AppRoutes.labRefMetricas')
  static const String tabelaMetricas = '/config/metricas';
}
