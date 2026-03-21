/**
 * ============================================================
 * DADOS: Absorção de Nutrientes em Soja
 * Autor: Raudinei Afonso
 * Extração para uso em projetos Flutter/Dart ou Web
 * ============================================================
 */

// ─── ESTÁDIOS FENOLÓGICOS ────────────────────────────────────
export const STADIOS = ['V1-V3', 'V4', 'V5', 'R1', 'R3', 'R5', 'R6'];
export const STADIOS_KEYS = ['V1_V3', 'V4', 'V5', 'R1', 'R3', 'R5', 'R6'];

// ─── NUTRIENTES ──────────────────────────────────────────────
export const MACRONUTRIENTES = ['N', 'P', 'K', 'Ca', 'Mg', 'S'];
export const MICRONUTRIENTES = ['B', 'Cu', 'Fe', 'Mn', 'Zn', 'Mo', 'Co', 'Ni', 'Se'];

export const NUTRIENTE_NOMES = {
  N:  'Nitrogênio (N)',
  P:  'Fósforo (P₂O₅)',
  K:  'Potássio (K)',
  Ca: 'Cálcio (Ca)',
  Mg: 'Magnésio (Mg)',
  S:  'Enxofre (S)',
  B:  'Boro (B)',
  Cu: 'Cobre (Cu)',
  Fe: 'Ferro (Fe)',
  Mn: 'Manganês (Mn)',
  Zn: 'Zinco (Zn)',
  Mo: 'Molibdênio (Mo)',
  Co: 'Cobalto (Co)',
  Ni: 'Níquel (Ni)',
  Se: 'Selênio (Se)',
};

export const NUTRIENTE_UNIDADES = {
  macro: 'kg/ton', // N, P, K, Ca, Mg, S
  micro: 'g/ton',  // B, Cu, Fe, Mn, Zn, Mo, Co, Ni, Se
};

// ─── CURVAS DE ABSORÇÃO (% do total absorvido em cada estádio acumulado) ──────
export const ABSORCAO_PERCENTUAIS = {
  N:  { V1_V3: 10,   V4: 25,   V5: 40,   R1: 55,  R3: 75,   R5: 90,   R6: 97.5 },
  P:  { V1_V3: 7.5,  V4: 17.5, V5: 30,   R1: 45,  R3: 70,   R5: 90,   R6: 97.5 },
  K:  { V1_V3: 12.5, V4: 30,   V5: 52.5, R1: 70,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Ca: { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 85,   R5: 97.5, R6: 97.5 },
  Mg: { V1_V3: 12.5, V4: 35,   V5: 55,   R1: 75,  R3: 92.5, R5: 97.5, R6: 97.5 },
  S:  { V1_V3: 15,   V4: 35,   V5: 55,   R1: 75,  R3: 92.5, R5: 97.5, R6: 97.5 },
  B:  { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Cu: { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Fe: { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Mn: { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Zn: { V1_V3: 7.5,  V4: 25,   V5: 45,   R1: 65,  R3: 87.5, R5: 97.5, R6: 97.5 },
  Mo: { V1_V3: 3.5,  V4: 12.5, V5: 25,   R1: 40,  R3: 77.5, R5: 92.5, R6: 97.5 },
  Co: { V1_V3: 3.5,  V4: 12.5, V5: 25,   R1: 40,  R3: 77.5, R5: 92.5, R6: 97.5 },
  Ni: { V1_V3: 3.5,  V4: 12.5, V5: 25,   R1: 40,  R3: 77.5, R5: 92.5, R6: 97.5 },
  Se: { V1_V3: 3.5,  V4: 12.5, V5: 25,   R1: 40,  R3: 77.5, R5: 92.5, R6: 97.5 },
};

// ─── ÍNDICES DE EXPORTAÇÃO (% da extração exportada nos grãos) ───────────────
export const INDICES_EXPORTACAO = {
  N:  { min: 50, max: 70,  descricao: '50–70%' },
  P:  { min: 70, max: 90,  descricao: '70–90%' },
  K:  { min: 50, max: 60,  descricao: '50–60%' },
  Ca: { min: 10, max: 20,  descricao: '10–20%' },
  Mg: { min: 20, max: 30,  descricao: '20–30%' },
  S:  { min: 20, max: 40,  descricao: '20–40%' },
  B:  { min: 20, max: 30,  descricao: '20–30%' },
  Cu: { min: 25, max: 35,  descricao: '25–35%' },
  Fe: { min: 15, max: 25,  descricao: '15–25%' },
  Mn: { min: 5,  max: 10,  descricao: '5–10%'  },
  Zn: { min: 25, max: 35,  descricao: '25–35%' },
  Mo: { min: 20, max: 40,  descricao: '20–40%' },
  Co: { min: 40, max: 50,  descricao: '40–50%' },
  Ni: { min: 20, max: 30,  descricao: '20–30%' },
  Se: { min: 60, max: 85,  descricao: '60–85%' },
};

// ─── DADOS POR FONTE ─────────────────────────────────────────
// Estrutura: { [tipoFonte]: { [fonte]: { Exportação: {...}, Extração: {...} } } }
// Unidades: macros = kg/ton | micros = g/ton
// Valor 0 = dado não disponível (calculado por índice de exportação)

export const NUTRIENT_DATA = {

  // ════════════════════════════════════════════════
  // AUTORES (Literatura científica)
  // ════════════════════════════════════════════════
  Autores: {

    'Araújo (2023)': {
      Exportação: { N: 41.36, P: 3.40,  K: 9.93,  Ca: 0.60,  Mg: 0.86, S: 1.28,  Cu: 4.32,  Fe: 8.93,   Zn: 15.64, Mn: 4.28,  B: 12.38, Se: 0, Co: 0, Mo: 0, Ni: 0 },
      Extração:   { N: 59.94, P: 5.23,  K: 18.74, Ca: 2.39,  Mg: 2.70, S: 2.98,  Cu: 8.63,  Fe: 44.67,  Zn: 31.28, Mn: 21.41, B: 32.58, Se: 0, Co: 0, Mo: 0, Ni: 0 },
    },

    'Kurihara et al. (2013) — só Exportação': {
      Exportação: { N: 42.33, P: 3.83,  K: 7.29,  Ca: 0.61,  Mg: 0.54, S: 2.78,  Cu: 13.48, Fe: 15.51,  Zn: 31.66, Mn: 5.39,  B: 10.07, Se: 0, Co: 0, Mo: 0, Ni: 0 },
      Extração:   { N: 0,     P: 0,     K: 0,     Ca: 0,     Mg: 0,    S: 0,     Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 0, Ni: 0 },
    },

    'Kurihara et al. (2013)138 — só Extração': {
      Exportação: { N: 0,     P: 0,     K: 0,     Ca: 0,     Mg: 0,    S: 0,     Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 0, Ni: 0 },
      Extração:   { N: 61.35, P: 5.89,  K: 13.76, Ca: 2.13,  Mg: 2.39, S: 5.96,  Cu: 26.92, Fe: 78.00,  Zn: 63.15, Mn: 27.10, B: 26.23, Se: 0, Co: 0, Mo: 0, Ni: 0 },
    },

    'Santos et al. (2008)': {
      Exportação: { N: 46.62, P: 2.61,  K: 10.52, Ca: 0.74,  Mg: 0.75, S: 0.89,  Cu: 27.39, Fe: 29.81,  Zn: 27.28, Mn: 5.86,  B: 9.11,  Se: 0, Co: 0, Mo: 0, Ni: 0 },
      Extração:   { N: 67.57, P: 4.02,  K: 19.84, Ca: 3.30,  Mg: 2.81, S: 2.06,  Cu: 52.98, Fe: 149.08, Zn: 53.38, Mn: 30.85, B: 23.09, Se: 0, Co: 0, Mo: 0, Ni: 0 },
    },

    'Bataglia & Mascarenhas (1977)': {
      Exportação: { N: 76.00, P: 5.70,  K: 32.00, Ca: 1.90,  Mg: 2.90, S: 3.10,  Cu: 26.00, Fe: 46.00,  Zn: 61.00, Mn: 13.00, B: 77.00, Se: 0, Co: 0, Mo: 6,  Ni: 0 },
      Extração:   { N: 64.00, P: 4.70,  K: 18.00, Ca: 11.60, Mg: 6.70, S: 0,     Cu: 14.00, Fe: 115.00, Zn: 43.00, Mn: 43.00, B: 24.00, Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'Borkert (1986)': {
      Exportação: { N: 82.00, P: 7.50,  K: 24.50, Ca: 11.80, Mg: 7.40, S: 15.00, Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 0,  Ni: 0 },
      Extração:   { N: 51.00, P: 7.60,  K: 17.00, Ca: 3.30,  Mg: 3.50, S: 5.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'Cordeiro et al. (1977)': {
      Exportação: { N: 77.40, P: 6.00,  K: 32.00, Ca: 13.40, Mg: 4.00, S: 8.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 0,  Ni: 0 },
      Extração:   { N: 64.40, P: 5.00,  K: 16.50, Ca: 2.90,  Mg: 2.40, S: 8.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'Darwich (1993)': {
      Exportação: { N: 82.00, P: 1.00,  K: 4.00,  Ca: 7.00,  Mg: 7.80, S: 7.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 7,  Ni: 0 },
      Extração:   { N: 58.80, P: 5.20,  K: 18.70, Ca: 1.90,  Mg: 2.10, S: 3.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'EMBRAPA': {
      Exportação: { N: 83.00, P: 8.40,  K: 25.00, Ca: 13.50, Mg: 7.30, S: 9.00,  Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 7,  Ni: 0 },
      Extração:   { N: 51.00, P: 1.00,  K: 2.00,  Ca: 3.10,  Mg: 2.00, S: 5.00,  Cu: 1,     Fe: 7,      Zn: 4,     Mn: 3,     B: 2,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'Portafos': {
      Exportação: { N: 83.00, P: 15.40, K: 38.00, Ca: 12.20, Mg: 7.30, S: 15.00, Cu: 1,     Fe: 0,      Zn: 4,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 7,  Ni: 0 },
      Extração:   { N: 51.00, P: 1.00,  K: 2.00,  Ca: 3.10,  Mg: 2.00, S: 5.00,  Cu: 1,     Fe: 7,      Zn: 4,     Mn: 3,     B: 2,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },

    'Tanaka et al. (1994)': {
      Exportação: { N: 82.00, P: 7.50,  K: 24.00, Ca: 12.00, Mg: 7.20, S: 15.00, Cu: 0,     Fe: 0,      Zn: 0,     Mn: 0,     B: 0,     Se: 0, Co: 0, Mo: 7,  Ni: 0 },
      Extração:   { N: 51.00, P: 5.00,  K: 17.00, Ca: 2.80,  Mg: 2.00, S: 5.00,  Cu: 1,     Fe: 218,    Zn: 4,     Mn: 3,     B: 2,     Se: 0, Co: 0, Mo: 5,  Ni: 0 },
    },
  },

  // ════════════════════════════════════════════════
  // GUIDORIZZI (por tecnologia de cultivo)
  // ════════════════════════════════════════════════
  Guidorizzi: {

    'Enlist': {
      Exportação: { N: 53.9,  P: 9.3,  K: 19.1,  Ca: 2.2,  Mg: 2.5,  S: 6.7,  Cu: 10.9, Fe: 122.3,  Zn: 46.5,  Mn: 14.1,  B: 37.3,  Se: 1.3, Co: 0.2, Mo: 3.2,  Ni: 0.4 },
      Extração:   { N: 142.9, P: 31.9, K: 120.8, Ca: 35.8, Mg: 13.6, S: 17.9, Cu: 37.5, Fe: 726.3,  Zn: 159.7, Mn: 195.4, B: 163.9, Se: 1.5, Co: 0.4, Mo: 12.4, Ni: 1.9 },
    },

    'Xtend': {
      Exportação: { N: 55.1,  P: 10.9, K: 19.6,  Ca: 2.3,  Mg: 2.5,  S: 8.6,  Cu: 12.7, Fe: 246.7,  Zn: 44.8,  Mn: 14.3,  B: 38.7,  Se: 1.1, Co: 0.2, Mo: 3.8, Ni: 0.5 },
      Extração:   { N: 179.9, P: 36.4, K: 127.6, Ca: 61.1, Mg: 18.9, S: 27.3, Cu: 42.6, Fe: 1106.9, Zn: 178.5, Mn: 309.9, B: 179.8, Se: 1.6, Co: 0.5, Mo: 9.2, Ni: 2.5 },
    },

    'Roundup Ready': {
      Exportação: { N: 55.6,  P: 9.3,  K: 20.6,  Ca: 2.1,  Mg: 2.6,  S: 8.3,  Cu: 11.0, Fe: 123.1,  Zn: 43.8,  Mn: 15.7,  B: 34.6,  Se: 1.7, Co: 0.2, Mo: 3.3,  Ni: 0.6 },
      Extração:   { N: 145.8, P: 29.4, K: 106.9, Ca: 43.5, Mg: 14.7, S: 22.2, Cu: 32.8, Fe: 673.9,  Zn: 140.1, Mn: 198.4, B: 160.1, Se: 2.2, Co: 0.5, Mo: 13.2, Ni: 2.2 },
    },
  },

  // ════════════════════════════════════════════════
  // CULTIVAR (dados por variedade genética)
  // ════════════════════════════════════════════════
  Cultivar: {

    '73i75RSF':           { Exportação: { N: 57.2, P: 5.5, K: 19.0, Ca: 2.2, Mg: 2.9, S: 2.9, Cu: 9.7,  Fe: 31.1,  Zn: 31.6, Mn: 2.5,  B: 3.9,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 82.9,  P: 8.46, K: 35.85, Ca: 8.8,  Mg: 9.06, S: 6.74, Cu: 19.4, Fe: 155.5, Zn: 63.2, Mn: 12.5,  B: 10.26, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    '75i74RSF':           { Exportação: { N: 56.4, P: 5.1, K: 17.1, Ca: 2.3, Mg: 2.8, S: 3.0, Cu: 1.1,  Fe: 285.3, Zn: 3.7,  Mn: 2.8,  B: 36.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 81.74, P: 7.85, K: 32.26, Ca: 9.2,  Mg: 8.75, S: 6.98, Cu: 2.2,  Fe: 1426.5,Zn: 7.4,  Mn: 14.0,  B: 96.32, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    '77EA40':             { Exportação: { N: 57.6, P: 5.1, K: 17.1, Ca: 2.3, Mg: 2.7, S: 2.7, Cu: 8.5,  Fe: 51.3,  Zn: 27.9, Mn: 18.6, B: 31.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.48, P: 7.85, K: 32.26, Ca: 9.2,  Mg: 8.44, S: 6.28, Cu: 17.0, Fe: 256.5, Zn: 55.8, Mn: 93.0,  B: 82.37, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'ADV4681 Ipro SR1':   { Exportação: { N: 62.9, P: 5.5, K: 19.3, Ca: 2.5, Mg: 3.0, S: 3.0, Cu: 8.1,  Fe: 29.2,  Zn: 49.0, Mn: 24.4, B: 35.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 91.16, P: 8.46, K: 36.42, Ca: 10.0, Mg: 9.38, S: 6.98, Cu: 16.2, Fe: 146.0, Zn: 98.0, Mn: 122.0, B: 92.11, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'ADV4681 Ipro SR2':   { Exportação: { N: 6.0,  P: 5.5, K: 21.0, Ca: 2.3, Mg: 2.9, S: 3.2, Cu: 8.4,  Fe: 26.0,  Zn: 42.2, Mn: 23.1, B: 31.9, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 8.7,   P: 8.46, K: 39.62, Ca: 9.2,  Mg: 9.06, S: 7.44, Cu: 16.8, Fe: 130.0, Zn: 84.4, Mn: 115.5, B: 83.95, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'ADV4681 Ipro SR3':   { Exportação: { N: 63.8, P: 5.4, K: 2.7,  Ca: 2.4, Mg: 2.7, S: 3.1, Cu: 8.4,  Fe: 17.2,  Zn: 37.4, Mn: 43.9, B: 31.8, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 92.46, P: 8.31, K: 5.09,  Ca: 9.6,  Mg: 8.44, S: 7.21, Cu: 16.8, Fe: 86.0,  Zn: 74.8, Mn: 219.5, B: 83.68, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'AS3595i2x':          { Exportação: { N: 66.9, P: 5.7, K: 19.2, Ca: 3.0, Mg: 3.3, S: 3.1, Cu: 1.0,  Fe: 34.5,  Zn: 35.1, Mn: 22.7, B: 35.4, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 96.96, P: 8.77, K: 36.23, Ca: 12.0, Mg:10.31, S: 7.21, Cu: 2.0,  Fe: 172.5, Zn: 70.2, Mn: 113.5, B: 93.16, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'AS3640i2x':          { Exportação: { N: 62.1, P: 5.6, K: 19.3, Ca: 1.7, Mg: 2.4, S: 3.2, Cu: 8.8,  Fe: 76.0,  Zn: 32.6, Mn: 18.8, B: 33.7, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 90.0,  P: 8.62, K: 36.42, Ca: 6.8,  Mg: 7.5,  S: 7.44, Cu: 17.6, Fe: 380.0, Zn: 65.2, Mn: 94.0,  B: 88.68, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'AS3700XTD':          { Exportação: { N: 59.4, P: 5.2, K: 18.6, Ca: 2.3, Mg: 2.3, S: 3.1, Cu: 8.1,  Fe: 48.5,  Zn: 27.8, Mn: 19.0, B: 29.8, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 86.09, P: 8.0,  K: 35.09, Ca: 9.2,  Mg: 7.19, S: 7.21, Cu: 16.2, Fe: 242.5, Zn: 55.6, Mn: 95.0,  B: 78.42, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'AS3707I2X':          { Exportação: { N: 59.9, P: 5.5, K: 19.3, Ca: 2.1, Mg: 2.5, S: 3.1, Cu: 8.2,  Fe: 29.8,  Zn: 28.6, Mn: 2.5,  B: 3.4,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 86.81, P: 8.46, K: 36.42, Ca: 8.4,  Mg: 7.81, S: 7.21, Cu: 16.4, Fe: 149.0, Zn: 57.2, Mn: 12.5,  B: 8.95,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'AS3790i2x':          { Exportação: { N: 61.5, P: 4.8, K: 18.0, Ca: 2.0, Mg: 2.5, S: 2.9, Cu: 8.4,  Fe: 58.7,  Zn: 25.3, Mn: 21.0, B: 28.7, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 89.13, P: 7.38, K: 33.96, Ca: 8.0,  Mg: 7.81, S: 6.74, Cu: 16.8, Fe: 293.5, Zn: 50.6, Mn: 105.0, B: 75.53, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CREDENZ CZ37B39':    { Exportação: { N: 6.7,  P: 5.4, K: 18.3, Ca: 2.5, Mg: 2.9, S: 3.0, Cu: 1.8,  Fe: 35.9,  Zn: 3.3,  Mn: 2.0,  B: 34.7, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.71,  P: 8.31, K: 34.53, Ca: 10.0, Mg: 9.06, S: 6.98, Cu: 3.6,  Fe: 179.5, Zn: 6.6,  Mn: 10.0,  B: 91.32, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ16B17 IPRO':       { Exportação: { N: 62.4, P: 5.5, K: 18.4, Ca: 2.5, Mg: 2.6, S: 2.9, Cu: 8.9,  Fe: 52.0,  Zn: 31.3, Mn: 19.8, B: 3.8,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 90.43, P: 8.46, K: 34.72, Ca: 10.0, Mg: 8.13, S: 6.74, Cu: 17.8, Fe: 260.0, Zn: 62.6, Mn: 99.0,  B: 10.0,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ37B39 I2X':        { Exportação: { N: 63.6, P: 5.1, K: 18.1, Ca: 2.6, Mg: 2.9, S: 3.3, Cu: 9.0,  Fe: 41.6,  Zn: 29.4, Mn: 22.9, B: 35.5, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 92.17, P: 7.85, K: 34.15, Ca: 10.4, Mg: 9.06, S: 7.67, Cu: 18.0, Fe: 208.0, Zn: 58.8, Mn: 114.5, B: 93.42, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ37B43':            { Exportação: { N: 61.8, P: 5.3, K: 18.5, Ca: 2.8, Mg: 3.1, S: 3.2, Cu: 8.8,  Fe: 3.5,   Zn: 27.5, Mn: 24.8, B: 34.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 89.57, P: 8.15, K: 34.91, Ca: 11.2, Mg: 9.69, S: 7.44, Cu: 17.6, Fe: 17.5,  Zn: 55.0, Mn: 124.0, B: 89.47, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ37B43 Ipro PM':    { Exportação: { N: 61.1, P: 5.5, K: 18.6, Ca: 2.2, Mg: 3.1, S: 2.9, Cu: 9.8,  Fe: 41.1,  Zn: 31.9, Mn: 19.4, B: 3.3,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 88.55, P: 8.46, K: 35.09, Ca: 8.8,  Mg: 9.69, S: 6.74, Cu: 19.6, Fe: 205.5, Zn: 63.8, Mn: 97.0,  B: 8.68,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ37B43 Ipro PO1':   { Exportação: { N: 53.0, P: 5.3, K: 17.9, Ca: 2.4, Mg: 2.9, S: 2.8, Cu: 7.8,  Fe: 12.6,  Zn: 28.7, Mn: 14.8, B: 3.1,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 76.81, P: 8.15, K: 33.77, Ca: 9.6,  Mg: 9.06, S: 6.51, Cu: 15.6, Fe: 63.0,  Zn: 57.4, Mn: 74.0,  B: 8.16,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'CZ37B43 Ipro PO2':   { Exportação: { N: 57.9, P: 5.3, K: 18.3, Ca: 2.8, Mg: 2.7, S: 2.6, Cu: 7.5,  Fe: 22.0,  Zn: 29.4, Mn: 14.9, B: 32.8, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.91, P: 8.15, K: 34.53, Ca: 11.2, Mg: 8.44, S: 6.05, Cu: 15.0, Fe: 110.0, Zn: 58.8, Mn: 74.5,  B: 86.32, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Dagma 7621':         { Exportação: { N: 57.8, P: 5.0, K: 17.8, Ca: 2.2, Mg: 2.6, S: 3.0, Cu: 9.1,  Fe: 44.2,  Zn: 3.4,  Mn: 21.5, B: 33.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.77, P: 7.69, K: 33.58, Ca: 8.8,  Mg: 8.13, S: 6.98, Cu: 18.2, Fe: 221.0, Zn: 6.8,  Mn: 107.5, B: 86.84, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Dagma 7921':         { Exportação: { N: 6.0,  P: 4.5, K: 18.2, Ca: 2.5, Mg: 2.9, S: 2.7, Cu: 7.8,  Fe: 47.0,  Zn: 27.8, Mn: 21.9, B: 28.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 8.7,   P: 6.92, K: 34.34, Ca: 10.0, Mg: 9.06, S: 6.28, Cu: 15.6, Fe: 235.0, Zn: 55.6, Mn: 109.5, B: 73.68, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Desafio PER1':       { Exportação: { N: 6.8,  P: 5.0, K: 19.2, Ca: 2.1, Mg: 2.6, S: 3.1, Cu: 1.4,  Fe: 23.7,  Zn: 37.6, Mn: 19.9, B: 33.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.86,  P: 7.69, K: 36.23, Ca: 8.4,  Mg: 8.13, S: 7.21, Cu: 2.8,  Fe: 118.5, Zn: 75.2, Mn: 99.5,  B: 86.84, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'DESAFIO 8473 RFS':   { Exportação: { N: 61.7, P: 4.5, K: 18.1, Ca: 2.5, Mg: 2.6, S: 2.9, Cu: 7.8,  Fe: 29.8,  Zn: 25.9, Mn: 23.1, B: 31.8, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 89.42, P: 6.92, K: 34.15, Ca: 10.0, Mg: 8.13, S: 6.74, Cu: 15.6, Fe: 149.0, Zn: 51.8, Mn: 115.5, B: 83.68, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Desafio RR BM1':     { Exportação: { N: 57.8, P: 5.5, K: 22.3, Ca: 2.3, Mg: 3.0, S: 3.1, Cu: 7.3,  Fe: 17.3,  Zn: 48.0, Mn: 27.7, B: 31.9, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.77, P: 8.46, K: 42.08, Ca: 9.2,  Mg: 9.38, S: 7.21, Cu: 14.6, Fe: 86.5,  Zn: 96.0, Mn: 138.5, B: 83.95, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Desafio RR BM2':     { Exportação: { N: 61.5, P: 5.2, K: 19.5, Ca: 2.3, Mg: 2.8, S: 3.1, Cu: 6.0,  Fe: 26.2,  Zn: 28.2, Mn: 18.7, B: 3.3,  Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 89.13, P: 8.0,  K: 36.79, Ca: 9.2,  Mg: 8.75, S: 7.21, Cu: 12.0, Fe: 131.0, Zn: 56.4, Mn: 93.5,  B: 8.68,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Desafio RR PER2':    { Exportação: { N: 58.2, P: 5.7, K: 2.3,  Ca: 2.0, Mg: 2.6, S: 3.4, Cu: 9.3,  Fe: 16.7,  Zn: 4.4,  Mn: 19.1, B: 34.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 84.35, P: 8.77, K: 4.34,  Ca: 8.0,  Mg: 8.13, S: 7.91, Cu: 18.6, Fe: 83.5,  Zn: 8.8,  Mn: 95.5,  B: 91.05, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Desafio RR VM':      { Exportação: { N: 57.8, P: 5.2, K: 19.6, Ca: 2.7, Mg: 2.6, S: 3.1, Cu: 9.1,  Fe: 22.7,  Zn: 34.3, Mn: 22.5, B: 31.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.77, P: 8.0,  K: 36.98, Ca: 10.8, Mg: 8.13, S: 7.21, Cu: 18.2, Fe: 113.5, Zn: 68.6, Mn: 112.5, B: 83.16, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'DM 69IX69':          { Exportação: { N: 59.9, P: 5.6, K: 18.2, Ca: 3.3, Mg: 2.8, S: 3.4, Cu: 7.2,  Fe: 3.1,   Zn: 25.8, Mn: 22.3, B: 32.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 86.81, P: 8.62, K: 34.34, Ca: 13.2, Mg: 8.75, S: 7.91, Cu: 14.4, Fe: 15.5,  Zn: 51.6, Mn: 111.5, B: 84.21, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'DM 72IX74':          { Exportação: { N: 61.3, P: 5.1, K: 18.1, Ca: 2.2, Mg: 2.7, S: 2.9, Cu: 9.6,  Fe: 31.6,  Zn: 29.2, Mn: 18.6, B: 28.4, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 88.84, P: 7.85, K: 34.15, Ca: 8.8,  Mg: 8.44, S: 6.74, Cu: 19.2, Fe: 158.0, Zn: 58.4, Mn: 93.0,  B: 74.74, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'DM 74K75':           { Exportação: { N: 63.2, P: 4.7, K: 19.2, Ca: 2.2, Mg: 2.4, S: 3.0, Cu: 7.6,  Fe: 36.7,  Zn: 26.7, Mn: 19.8, B: 35.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 91.59, P: 7.23, K: 36.23, Ca: 8.8,  Mg: 7.5,  S: 6.98, Cu: 15.2, Fe: 183.5, Zn: 53.4, Mn: 99.0,  B: 92.89, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'DM 76IX77':          { Exportação: { N: 59.3, P: 4.7, K: 16.1, Ca: 2.2, Mg: 2.2, S: 2.9, Cu: 8.0,  Fe: 48.1,  Zn: 26.9, Mn: 21.5, B: 34.8, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 85.94, P: 7.23, K: 30.38, Ca: 8.8,  Mg: 6.88, S: 6.74, Cu: 16.0, Fe: 240.5, Zn: 53.8, Mn: 107.5, B: 91.58, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Exata i2x 64IX60RFS':{ Exportação: { N: 6.0,  P: 5.4, K: 17.9, Ca: 2.1, Mg: 2.8, S: 2.9, Cu: 7.7,  Fe: 38.2,  Zn: 26.5, Mn: 19.1, B: 34.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 8.7,   P: 8.31, K: 33.77, Ca: 8.4,  Mg: 8.75, S: 6.74, Cu: 15.4, Fe: 191.0, Zn: 53.0, Mn: 95.5,  B: 89.47, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'FOCO 74177 RFS':     { Exportação: { N: 56.2, P: 5.5, K: 18.8, Ca: 2.6, Mg: 2.7, S: 3.1, Cu: 8.4,  Fe: 26.0,  Zn: 31.5, Mn: 21.9, B: 36.5, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 81.45, P: 8.46, K: 35.47, Ca: 10.4, Mg: 8.44, S: 7.21, Cu: 16.8, Fe: 130.0, Zn: 63.0, Mn: 109.5, B: 96.05, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Guepardo IPRO 67168':{ Exportação: { N: 63.2, P: 5.5, K: 17.6, Ca: 3.1, Mg: 2.6, S: 3.0, Cu: 8.5,  Fe: 32.6,  Zn: 3.5,  Mn: 21.4, B: 29.1, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 91.59, P: 8.46, K: 33.21, Ca: 12.4, Mg: 8.13, S: 6.98, Cu: 17.0, Fe: 163.0, Zn: 7.0,  Mn: 107.0, B: 76.58, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'HO PARAGUAÇU I2X':   { Exportação: { N: 57.5, P: 5.1, K: 17.8, Ca: 1.8, Mg: 2.4, S: 3.0, Cu: 7.2,  Fe: 38.1,  Zn: 25.5, Mn: 18.9, B: 35.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.33, P: 7.85, K: 33.58, Ca: 7.2,  Mg: 7.5,  S: 6.98, Cu: 14.4, Fe: 190.5, Zn: 51.0, Mn: 94.5,  B: 92.11, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'HO TAQUARI 80H0110': { Exportação: { N: 6.3,  P: 4.9, K: 18.0, Ca: 2.3, Mg: 2.6, S: 2.9, Cu: 1.3,  Fe: 69.7,  Zn: 25.3, Mn: 2.8,  B: 32.9, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.13,  P: 7.54, K: 33.96, Ca: 9.2,  Mg: 8.13, S: 6.74, Cu: 2.6,  Fe: 348.5, Zn: 50.6, Mn: 14.0,  B: 86.58, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Juruena Ipro SR1':   { Exportação: { N: 54.3, P: 5.1, K: 21.8, Ca: 2.6, Mg: 2.5, S: 2.9, Cu: 6.1,  Fe: 1.3,   Zn: 34.3, Mn: 24.0, B: 32.9, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 78.7,  P: 7.85, K: 41.13, Ca: 10.4, Mg: 7.81, S: 6.74, Cu: 12.2, Fe: 6.5,   Zn: 68.6, Mn: 120.0, B: 86.58, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Juruena Ipro SR2':   { Exportação: { N: 55.4, P: 5.3, K: 2.9,  Ca: 2.8, Mg: 2.7, S: 2.8, Cu: 7.5,  Fe: 17.1,  Zn: 4.7,  Mn: 22.4, B: 35.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 80.29, P: 8.15, K: 5.47,  Ca: 11.2, Mg: 8.44, S: 6.51, Cu: 15.0, Fe: 85.5,  Zn: 9.4,  Mn: 112.0, B: 92.89, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Juruena Ipro SR3':   { Exportação: { N: 58.0, P: 5.8, K: 21.8, Ca: 2.5, Mg: 2.6, S: 2.9, Cu: 7.4,  Fe: 15.1,  Zn: 44.9, Mn: 29.9, B: 39.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 84.06, P: 8.92, K: 41.13, Ca: 10.0, Mg: 8.13, S: 6.74, Cu: 14.8, Fe: 75.5,  Zn: 89.8, Mn: 149.5, B:104.21, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'K7922I2X':           { Exportação: { N: 61.4, P: 5.0, K: 19.4, Ca: 2.2, Mg: 2.8, S: 3.1, Cu: 1.0,  Fe: 42.9,  Zn: 31.9, Mn: 21.2, B: 32.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 88.99, P: 7.69, K: 36.6,  Ca: 8.8,  Mg: 8.75, S: 7.21, Cu: 2.0,  Fe: 214.5, Zn: 63.8, Mn: 106.0, B: 85.0,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'LENDARIA 80K80 RFS': { Exportação: { N: 6.7,  P: 4.9, K: 19.1, Ca: 2.4, Mg: 2.5, S: 2.7, Cu: 8.2,  Fe: 78.6,  Zn: 27.6, Mn: 19.1, B: 25.1, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.71,  P: 7.54, K: 36.04, Ca: 9.6,  Mg: 7.81, S: 6.28, Cu: 16.4, Fe: 393.0, Zn: 55.2, Mn: 95.5,  B: 66.05, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'M 6430 XTD':         { Exportação: { N: 62.4, P: 4.8, K: 17.3, Ca: 3.0, Mg: 3.0, S: 3.1, Cu: 7.7,  Fe: 73.4,  Zn: 23.6, Mn: 22.4, B: 26.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 90.43, P: 7.38, K: 32.64, Ca: 12.0, Mg: 9.38, S: 7.21, Cu: 15.4, Fe: 367.0, Zn: 47.2, Mn: 112.0, B: 70.0,  Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'M6100 XTD':          { Exportação: { N: 6.7,  P: 5.3, K: 19.0, Ca: 2.0, Mg: 2.5, S: 2.9, Cu: 8.9,  Fe: 25.3,  Zn: 26.7, Mn: 18.8, B: 32.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.71,  P: 8.15, K: 35.85, Ca: 8.0,  Mg: 7.81, S: 6.74, Cu: 17.8, Fe: 126.5, Zn: 53.4, Mn: 94.0,  B: 84.21, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'M6110 i2x':          { Exportação: { N: 57.3, P: 5.6, K: 18.5, Ca: 2.2, Mg: 2.5, S: 2.9, Cu: 9.6,  Fe: 56.6,  Zn: 33.1, Mn: 22.0, B: 31.4, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.04, P: 8.62, K: 34.91, Ca: 8.8,  Mg: 7.81, S: 6.74, Cu: 19.2, Fe: 283.0, Zn: 66.2, Mn: 110.0, B: 82.63, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'M6210 Ipro':         { Exportação: { N: 58.6, P: 5.2, K: 19.9, Ca: 2.2, Mg: 2.6, S: 3.0, Cu: 8.4,  Fe: 28.8,  Zn: 28.7, Mn: 2.6,  B: 31.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 84.93, P: 8.0,  K: 37.55, Ca: 8.8,  Mg: 8.13, S: 6.98, Cu: 16.8, Fe: 144.0, Zn: 57.4, Mn: 13.0,  B: 82.37, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'NEO750':             { Exportação: { N: 6.4,  P: 4.9, K: 16.7, Ca: 2.5, Mg: 2.6, S: 2.9, Cu: 9.0,  Fe: 86.5,  Zn: 3.5,  Mn: 2.7,  B: 38.7, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 9.28,  P: 7.54, K: 31.51, Ca: 10.0, Mg: 8.13, S: 6.74, Cu: 18.0, Fe: 432.5, Zn: 7.0,  Mn: 13.5,  B:101.84, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'NEOGEN 680':         { Exportação: { N: 61.3, P: 5.9, K: 18.8, Ca: 2.4, Mg: 2.4, S: 3.2, Cu: 1.0,  Fe: 4.6,   Zn: 29.3, Mn: 18.7, B: 34.9, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 88.84, P: 9.08, K: 35.47, Ca: 9.6,  Mg: 7.5,  S: 7.44, Cu: 2.0,  Fe: 23.0,  Zn: 58.6, Mn: 93.5,  B: 91.84, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'NEOGEN 71E':         { Exportação: { N: 59.2, P: 5.4, K: 17.8, Ca: 2.2, Mg: 2.8, S: 3.0, Cu: 9.0,  Fe: 143.1, Zn: 29.0, Mn: 19.0, B: 28.6, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 85.8,  P: 8.31, K: 33.58, Ca: 8.8,  Mg: 8.75, S: 6.98, Cu: 18.0, Fe: 715.5, Zn: 58.0, Mn: 95.0,  B: 75.26, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'NEOGEN 720':         { Exportação: { N: 57.3, P: 5.3, K: 18.8, Ca: 2.7, Mg: 2.9, S: 3.0, Cu: 9.6,  Fe: 3.8,   Zn: 29.4, Mn: 22.9, B: 34.4, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 83.04, P: 8.15, K: 35.47, Ca: 10.8, Mg: 9.06, S: 6.98, Cu: 19.2, Fe: 19.0,  Zn: 58.8, Mn: 114.5, B: 90.53, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'NEOGEN 770':         { Exportação: { N: 59.3, P: 5.2, K: 16.3, Ca: 2.7, Mg: 2.7, S: 3.0, Cu: 9.4,  Fe: 51.0,  Zn: 32.2, Mn: 21.2, B: 38.0, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 85.94, P: 8.0,  K: 30.75, Ca: 10.8, Mg: 8.44, S: 6.98, Cu: 18.8, Fe: 255.0, Zn: 64.4, Mn: 106.0, B: 100.0, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'Olimpo 80182 RFS':   { Exportação: { N: 63.2, P: 4.6, K: 18.4, Ca: 2.6, Mg: 2.9, S: 2.6, Cu: 8.8,  Fe: 37.9,  Zn: 26.3, Mn: 19.9, B: 35.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 91.59, P: 7.08, K: 34.72, Ca: 10.4, Mg: 9.06, S: 6.05, Cu: 17.6, Fe: 189.5, Zn: 52.6, Mn: 99.5,  B: 92.89, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
    'SUPERA i2x 73IX74':  { Exportação: { N: 62.9, P: 5.4, K: 17.7, Ca: 2.2, Mg: 2.7, S: 2.8, Cu: 9.8,  Fe: 37.9,  Zn: 29.8, Mn: 2.4,  B: 29.3, Se: 0, Co: 0, Mo: 0, Ni: 0 }, Extração: { N: 91.16, P: 8.31, K: 33.4,  Ca: 8.8,  Mg: 8.44, S: 6.51, Cu: 19.6, Fe: 189.5, Zn: 59.6, Mn: 12.0,  B: 77.11, Se: 0, Co: 0, Mo: 0, Ni: 0 } },
  },
};

// ─── HELPERS ─────────────────────────────────────────────────

/** Retorna se um nutriente é macro (true) ou micro (false) */
export function isMacro(nutrient) {
  return MACRONUTRIENTES.includes(nutrient);
}

/**
 * Calcula a absorção por estádio (kg ou g) para uma produtividade dada
 * @param {string} sourceType - 'Autores' | 'Guidorizzi' | 'Cultivar'
 * @param {string} source     - nome do autor/cultivar
 * @param {string} nutrient   - símbolo do nutriente
 * @param {string} dataType   - 'Exportação' | 'Extração'
 * @param {number} yieldTons  - produtividade em ton/ha
 * @param {string} mode       - 'perStage' | 'accumulated'
 * @returns {{ stage: string, percentage: number, value: number, unit: string }[]}
 */
export function calcAbsorption(sourceType, source, nutrient, dataType, yieldTons, mode = 'accumulated') {
  const baseValue = NUTRIENT_DATA[sourceType]?.[source]?.[dataType]?.[nutrient] ?? 0;
  const percentages = ABSORCAO_PERCENTUAIS[nutrient];
  const macro = isMacro(nutrient);
  const valuePerTon = macro ? baseValue : baseValue / 1000;
  const totalKg = valuePerTon * yieldTons;
  const unit = totalKg < 1 ? 'g' : 'kg';
  const multiplier = unit === 'g' ? 1000 : 1;

  return STADIOS_KEYS.map((key, index) => {
    const cumPct = percentages[key];
    const prevPct = index > 0 ? percentages[STADIOS_KEYS[index - 1]] : 0;
    const pct = mode === 'accumulated' ? cumPct : cumPct - prevPct;
    const value = (pct / 100) * totalKg * multiplier;
    return { stage: STADIOS[index], percentage: pct, value: parseFloat(value.toFixed(4)), unit };
  });
}

/** Lista todos os tipos de fonte disponíveis */
export function getSourceTypes() {
  return Object.keys(NUTRIENT_DATA);
}

/** Lista todas as fontes dentro de um tipo */
export function getSources(sourceType) {
  return Object.keys(NUTRIENT_DATA[sourceType] ?? {});
}
