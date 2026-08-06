/// Abas do detalhe do cliente — usadas por rotas e TabController.
enum ClienteDetailTab {
  resumo(0),
  propriedades(1),
  talhoes(2),
  analises(3),
  recomendacoes(4);

  const ClienteDetailTab(this.tabIndex);

  final int tabIndex;

  static ClienteDetailTab fromQuery(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'propriedades':
      case 'propriedade':
        return ClienteDetailTab.propriedades;
      case 'talhoes':
      case 'talhao':
        return ClienteDetailTab.talhoes;
      case 'analises':
      case 'analise':
        return ClienteDetailTab.analises;
      case 'recomendacoes':
      case 'recomendacao':
        return ClienteDetailTab.recomendacoes;
      default:
        return ClienteDetailTab.resumo;
    }
  }
}
