import 'package:flutter/material.dart';

enum Cultura { soja, milho, feijao, algodao, arroz, sorgo }

enum TexturaSolo { argiloso, medio, arenoso }

extension CulturaExtension on Cultura {
  String get label {
    switch (this) {
      case Cultura.soja:    return 'Soja';
      case Cultura.milho:   return 'Milho';
      case Cultura.feijao:  return 'Feijão';
      case Cultura.algodao: return 'Algodão';
      case Cultura.arroz:   return 'Arroz';
      case Cultura.sorgo:   return 'Sorgo';
    }
  }

  Color get color {
    switch (this) {
      case Cultura.soja:    return const Color(0xFF34C759);
      case Cultura.milho:   return const Color(0xFFFF9500);
      case Cultura.feijao:  return const Color(0xFFFF3B30);
      case Cultura.algodao: return const Color(0xFF007AFF);
      case Cultura.arroz:   return const Color(0xFF5AC8FA);
      case Cultura.sorgo:   return const Color(0xFFAF52DE);
    }
  }

  String get emoji {
    switch (this) {
      case Cultura.soja:    return '🌱';
      case Cultura.milho:   return '🌽';
      case Cultura.feijao:  return '🫘';
      case Cultura.algodao: return '☁️';
      case Cultura.arroz:   return '🌾';
      case Cultura.sorgo:   return '🌿';
    }
  }
}

class AnaliseSolo {
  final String id;
  final String produtorId;
  final String nomeArea;
  final Cultura cultura;
  final String safra;              // ex: "2025/26"
  final String laboratorio;
  final DateTime dataCadastro;

  // Localização
  final double? latitude;
  final double? longitude;
  final String? descricaoLocal;

  // Físico
  final TexturaSolo textura;
  final String profundidade;       // ex: "0-20 cm"

  // pH
  final double? phAgua;
  final double? phSmp;
  final double? phCacl2;

  // Macronutrientes
  final double? fosforo;           // mg/dm³
  final double? potassio;          // cmolc/dm³
  final double? calcio;            // cmolc/dm³
  final double? magnesio;          // cmolc/dm³
  final double? enxofre;           // mg/dm³

  // Acidez
  final double? aluminio;          // cmolc/dm³
  final double? hMaisAl;           // cmolc/dm³

  // Calculados (getters)
  double get ctc => (calcio ?? 0) + (magnesio ?? 0) + (potassio ?? 0) + (hMaisAl ?? 0);
  double get vPorcento {
    if (ctc == 0) return 0;
    return ((calcio ?? 0) + (magnesio ?? 0) + (potassio ?? 0)) / ctc * 100;
  }

  // Micronutrientes
  final double? boro;
  final double? cobre;
  final double? ferro;
  final double? manganes;
  final double? zinco;

  // Laudo
  final String? pdfUrl;

  const AnaliseSolo({
    required this.id,
    required this.produtorId,
    required this.nomeArea,
    required this.cultura,
    required this.safra,
    required this.laboratorio,
    required this.dataCadastro,
    this.latitude,
    this.longitude,
    this.descricaoLocal,
    required this.textura,
    required this.profundidade,
    this.phAgua,
    this.phSmp,
    this.phCacl2,
    this.fosforo,
    this.potassio,
    this.calcio,
    this.magnesio,
    this.enxofre,
    this.aluminio,
    this.hMaisAl,
    this.boro,
    this.cobre,
    this.ferro,
    this.manganes,
    this.zinco,
    this.pdfUrl,
  });
}
