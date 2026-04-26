import 'package:soloforte/domain/entities/lab_info.dart';

const ibraLabInfo = LabInfo(
  id: 'ibra',
  nome: 'IBRA — Instituto Brasileiro de Análises',
  cnpj: '',
  extratores: {
    'p': 'Resina (IAC)',
    'caMgAlK': 'KCl 1M',
    's': 'Fosfato de Cálcio Monobásico',
    'cuFeMnZn': 'DTPA — IAC',
    'b': 'ME SOLO 03',
  },
);

/// Mapeamento dos campos do JSON IBRA → campo interno do JSON.
///
/// Particularidades:
/// - K, Ca, Mg, Al, H+Al: vêm em mmolc/dm³ → ImportService converte ÷ 10
/// - M.O. e COT: g/dm³ → ImportService converte ÷ 10 para dag/kg
/// - Não tem P Mehlich neste laudo — pMehlich = null
/// - Micronutrientes pelo extrator DTPA (IAC)
const ibraFieldMap = {
  // Identificação
  'numeroLab': 'numeroAmostra',
  'talhao': 'talhao',
  'profundidade': 'profundidade',

  // pH
  'pH CaCl2': 'phCaCl2',
  'pH SMP': 'phSmp',

  // Fósforo — Resina (IAC)
  'P Resina': 'pResina',
  'P Rem': 'pRem',

  // Matéria Orgânica e Carbono — g/dm³; ImportService converte ÷ 10
  'M.O.': 'mo_gdm3',
  'COT': 'cot_gdm3',

  // Macronutrientes — mmolc/dm³; ImportService converte ÷ 10
  'K': 'k_mmolc',
  'Ca': 'ca_mmolc',
  'Mg': 'mg_mmolc',
  'Al': 'al_mmolc',
  'H + Al': 'hMaisAl_mmolc',

  // Enxofre
  'S': 's020',

  // Micronutrientes — DTPA
  'B': 'b',
  'Cu': 'cu',
  'Fe': 'fe',
  'Mn': 'mn',
  'Zn': 'zn',

  // Composição Física — g/kg
  'Argila': 'argila',
  'Silte': 'silte',
  'Areia Total': 'areiaTotal',
};

/// Campos calculados presentes no laudo IBRA que devem ser ignorados no import.
const ibraIgnoredFields = {
  'Na na CTC',
  'Ca na CTC',
  'Mg na CTC',
  'K na CTC',
  'H',
  'SB',
  'CTC',
  'V',
  'm',
};
