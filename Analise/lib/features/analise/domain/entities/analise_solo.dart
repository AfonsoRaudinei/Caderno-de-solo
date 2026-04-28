import 'package:flutter/material.dart';

enum Cultura { soja, milho, feijao, algodao, arroz, sorgo }

extension CulturaExtension on Cultura {
  String get label {
    switch (this) {
      case Cultura.soja:
        return 'Soja';
      case Cultura.milho:
        return 'Milho';
      case Cultura.feijao:
        return 'Feijão';
      case Cultura.algodao:
        return 'Algodão';
      case Cultura.arroz:
        return 'Arroz';
      case Cultura.sorgo:
        return 'Sorgo';
    }
  }

  Color get color {
    switch (this) {
      case Cultura.soja:
        return const Color(0xFF34C759);
      case Cultura.milho:
        return const Color(0xFFFF9500);
      case Cultura.feijao:
        return const Color(0xFFFF3B30);
      case Cultura.algodao:
        return const Color(0xFF007AFF);
      case Cultura.arroz:
        return const Color(0xFF5AC8FA);
      case Cultura.sorgo:
        return const Color(0xFFAF52DE);
    }
  }

  String get emoji {
    switch (this) {
      case Cultura.soja:
        return '🌱';
      case Cultura.milho:
        return '🌽';
      case Cultura.feijao:
        return '🫘';
      case Cultura.algodao:
        return '☁️';
      case Cultura.arroz:
        return '🌾';
      case Cultura.sorgo:
        return '🌿';
    }
  }
}

class AnaliseSolo {
  final String id;
  final String fazenda;
  final String produtor;
  final String talhao;
  final String numeroAmostra;
  final Cultura cultura;
  final String safra; // ex: "2025/26"
  final String laboratorio;
  final DateTime dataCadastro;
  final String profundidade; // ex: "0-20"

  // Localização (infra)
  final double? latitude;
  final double? longitude;
  final String? descricaoLocal;

  // Composição física
  final double? argila; // g/kg
  final double? silte; // g/kg
  final double? areiaTotal; // g/kg

  // pH
  final double? phAgua;
  final double? phSmp;
  final double? phCaCl2;

  // Matéria orgânica
  final double? materiaOrganica; // dag/kg
  final double? carbonoOrganico; // dag/kg

  // Fósforo
  final double? pMehlich; // mg/dm³
  final double? pResina; // mg/dm³
  final double? pRem; // mg/L

  // Enxofre
  final double? s020; // mg/dm³
  final double? s2040; // mg/dm³

  // Macronutrientes
  final double? k; // cmolc/dm³
  final double? ca; // cmolc/dm³
  final double? mg; // cmolc/dm³
  final double? al; // cmolc/dm³
  final double? hMaisAl; // cmolc/dm³
  final double? na; // cmolc/dm³

  // Micronutrientes
  final double? b;
  final double? cu;
  final double? fe;
  final double? mn;
  final double? zn;
  final double? ni;
  final double? mo;
  final double? se;

  // Infra
  final String? pdfUrl;
  final Map<String, dynamic>? laudoMetadata;

  const AnaliseSolo({
    required this.id,
    required this.fazenda,
    required this.produtor,
    required this.talhao,
    required this.numeroAmostra,
    required this.cultura,
    required this.safra,
    required this.laboratorio,
    required this.dataCadastro,
    required this.profundidade,
    this.latitude,
    this.longitude,
    this.descricaoLocal,
    this.argila,
    this.silte,
    this.areiaTotal,
    this.phAgua,
    this.phSmp,
    this.phCaCl2,
    this.materiaOrganica,
    this.carbonoOrganico,
    this.pMehlich,
    this.pResina,
    this.pRem,
    this.s020,
    this.s2040,
    this.k,
    this.ca,
    this.mg,
    this.al,
    this.hMaisAl,
    this.na,
    this.b,
    this.cu,
    this.fe,
    this.mn,
    this.zn,
    this.ni,
    this.mo,
    this.se,
    this.pdfUrl,
    this.laudoMetadata,
  });
}
