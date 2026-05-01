class ClassificacaoNivel {
  static String classificar({
    required String nutriente,
    required double valor,
    double? argila,
  }) {
    switch (nutriente.toLowerCase()) {
      case 'ph':
        if (valor < 4.5) return 'Muito Baixo';
        if (valor <= 5.0) return 'Baixo';
        if (valor <= 5.5) return 'Médio';
        if (valor <= 6.0) return 'Adequado';
        if (valor <= 7.0) return 'Alto';
        return 'Muito Alto';
      case 'vpercent':
        if (valor < 25) return 'Muito Baixo';
        if (valor <= 40) return 'Baixo';
        if (valor <= 60) return 'Médio';
        if (valor <= 75) return 'Adequado';
        if (valor <= 90) return 'Alto';
        return 'Muito Alto';
      case 'ca':
        if (valor < 0.5) return 'Muito Baixo';
        if (valor <= 1.5) return 'Baixo';
        if (valor <= 3.0) return 'Médio';
        if (valor <= 6.0) return 'Adequado';
        return 'Alto';
      case 'mg':
        if (valor < 0.3) return 'Muito Baixo';
        if (valor <= 0.8) return 'Baixo';
        if (valor <= 1.5) return 'Médio';
        if (valor <= 3.0) return 'Adequado';
        return 'Alto';
      case 'k':
        if (valor < 0.08) return 'Muito Baixo';
        if (valor <= 0.15) return 'Baixo';
        if (valor <= 0.30) return 'Médio';
        if (valor <= 0.60) return 'Adequado';
        return 'Alto';
      case 'p':
        double nc = 8.0;
        if (argila != null) {
          if (argila > 60) { nc = 4.0; }
          else if (argila < 15) { nc = 15.0; }
        }
        if (valor < 0.5 * nc) return 'Muito Baixo';
        if (valor <= 0.8 * nc) return 'Baixo';
        if (valor <= 1.0 * nc) return 'Médio';
        if (valor <= 2.0 * nc) return 'Adequado';
        return 'Alto';
      case 'mo':
        if (valor < 10) return 'Muito Baixo';
        if (valor <= 20) return 'Baixo';
        if (valor <= 30) return 'Médio';
        if (valor <= 40) return 'Adequado';
        return 'Alto';
      case 's':
        if (valor < 5) return 'Muito Baixo';
        if (valor <= 10) return 'Baixo';
        if (valor <= 20) return 'Médio';
        return 'Adequado';
      default:
        return 'Indeterminado';
    }
  }
}

class NivelEscala {
  static (double, double) escala(String nutriente, {double? argila}) {
    switch (nutriente.toLowerCase()) {
      case 'ph': return (4.0, 7.5);
      case 'vpercent': return (0.0, 100.0);
      case 'ca': return (0.0, 8.0);
      case 'mg': return (0.0, 4.0);
      case 'k': return (0.0, 0.80);
      case 'p': return (0.0, 30.0);
      case 'mo': return (0.0, 50.0);
      case 's': return (0.0, 30.0);
      default: return (0.0, 10.0);
    }
  }
}
