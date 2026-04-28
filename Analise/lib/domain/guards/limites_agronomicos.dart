class LimitesAgronomicos {
  const LimitesAgronomicos._();

  static double limitarP(double valor) {
    if (valor > 500) return 500;
    if (valor < 0) return 0;
    return valor;
  }

  static double limitarK(double valor) {
    if (valor > 20) return 20;
    if (valor < 0) return 0;
    return valor;
  }
}
