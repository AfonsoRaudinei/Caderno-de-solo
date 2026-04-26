import 'package:soloforte/domain/entities/lab_info.dart';

const exataBrasilLabInfo = LabInfo(
  id: 'exata_brasil',
  nome: 'Exata Brasil',
  cnpj: '',
  extratores: {
    'p_mehlich': 'Mehlich-1',
    'p_resina': 'Resina',
    'cuFeMnZn_meh': 'Mehlich',
    'cuFeMnZn_dtpa': 'DTPA',
    'caMgAl': 'KCl 1M',
    's': 'Fosfato monobásico de Cálcio',
    'b': 'Água quente',
  },
);

/// Mapeamento dos campos do JSON Exata Brasil → campo canônico no JSON.
///
/// Particularidades:
/// - K vem em mg/dm³ (k_mgdm3) → converter ÷ 391 para cmolc/dm³
/// - M.O. e C.O. vêm em g/dm³ → converter ÷ 10 para dag/kg
/// - Micronutrientes guardados em dois extratores (Mehlich e DTPA);
///   o campo canônico `cu/fe/mn/zn` recebe o valor DTPA como principal.
const exataBrasilFieldMap = {
  // Identificação (vem do cabeçalho)
  'descricaoAmostra': 'talhao',
  'amostra': 'numeroAmostra',
  'profundidade': 'profundidade',

  // pH
  'pH (CaCl2)': 'phCaCl2',
  'pH (SMP)': 'phSmp',

  // Matéria Orgânica — unidade g/dm³ → importService converte ÷ 10 para dag/kg
  'M.O.': 'materiaOrganica',
  'C.O.': 'carbonoOrganico',

  // Fósforo
  'P (meh)': 'pMehlich',
  'P (res)': 'pResina',
  'P (rem)': 'pRem',

  // Enxofre
  'S': 's020',

  // Macronutrientes
  // K vem em mg/dm³ no JSON (campo k_mgdm3); ImportService converte ÷ 391
  'K (NH4Cl)': 'k_mgdm3',
  'Ca': 'ca',
  'Mg': 'mg',
  'Al': 'al',
  'H + Al': 'hMaisAl',
  'Na': 'na',

  // Micronutrientes — DTPA como principal no canônico
  'Cu (DTPA)': 'cu',
  'Fe (DTPA)': 'fe',
  'Mn (DTPA)': 'mn',
  'Zn (DTPA)': 'zn',
  'B': 'b',

  // Composição Física
  'Argila': 'argila',
  'Silte': 'silte',
  'Areia': 'areiaTotal',
};

/// Campos presentes no JSON Exata Brasil que não mapeiam para o canônico.
const exataBrasilIgnoredFields = {
  'Ca + Mg', // derivado; recalcular de ca + mg
  'cu_meh',
  'fe_meh',
  'mn_meh',
  'zn_meh',
};
