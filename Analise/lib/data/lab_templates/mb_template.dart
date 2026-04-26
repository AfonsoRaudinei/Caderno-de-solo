import 'package:soloforte/domain/entities/lab_info.dart';

const mbLabInfo = LabInfo(
  id: 'mb_agronegocios',
  nome: 'MB Agronegócios',
  cnpj: '',
  extratores: {
    'p_mehlich': 'Mehlich-1',
    'p_resina': 'Resina',
    'caMgAlHAl': 'cmol/dm³ (sem conversão)',
    'k': 'mg/dm³ (÷ 391)',
    'b': 'Água quente',
  },
);

/// Mapeamento dos campos do JSON MB Agronegócios → campo interno do JSON.
///
/// Particularidades:
/// - Ca, Mg, Al, H+Al em cmol/dm³ = cmolc/dm³ → sem conversão
/// - K em mg/dm³ (k_mgdm3) → ImportService converte ÷ 391
/// - M.O. em % = dag/kg → sem conversão
/// - Carbono em g/dm³ → ImportService converte ÷ 10 para dag/kg
/// - Argila, Silte, Areia em % → ImportService converte × 10 para g/kg
/// - Campos "nr" (não requisitado) → null
const mbFieldMap = {
  // Identificação
  'numeroAnalise': 'numeroAmostra',
  'talhao': 'talhao',
  'profundidade': 'profundidade',

  // pH
  'pH CaCl2': 'phCaCl2',

  // Fósforo
  'P-meh': 'pMehlich',
  'P-REMANESCENTE': 'pRem',
  'P-RESINA': 'pResina',

  // K — mg/dm³; ImportService converte ÷ 391
  'K': 'k_mgdm3',

  // Macronutrientes — cmol/dm³ (sem conversão)
  'Ca': 'ca',
  'Mg': 'mg',
  'Al': 'al',
  'H+Al': 'hMaisAl',

  // Matéria Orgânica — % = dag/kg; sem conversão
  'M.O.': 'mo_pct',
  // Carbono — g/dm³; ImportService converte ÷ 10
  'Carbono': 'carbono_gdm3',

  // Enxofre — nr → null
  'S': 's020',

  // Micronutrientes — nr → null
  'B': 'b',
  'Cu': 'cu',
  'Fe': 'fe',
  'Mn': 'mn',
  'Zn': 'zn',

  // Composição Física — % → ImportService converte × 10 para g/kg
  'Argila': 'argila_pct',
  'Silte': 'silte_pct',
  'Areia Total': 'areiaTotal_pct',
};

const mbIgnoredFields = {
  'P-REMANESCENTE', // guardado como pRem, não é derivado canônico
  'nr',
};
