import 'package:soloforte/domain/entities/lab_info.dart';

// K vem em mg/dm³ no JSON (campo k_mgdm3); ImportService converte ÷ 391
// Ref: Conversoes.kMgDm3Factor = 391
const sellarLabInfo = LabInfo(
  id: 'sellar',
  nome: 'Sellar Análises Agrícolas',
  cnpj: '17.985.831/0001-62',
  extratores: {
    'pk': 'Mehlich 1',
    'cuFeMnZn': 'DTPA',
    'caMgAl': 'KCl 1M',
    's': 'Fosfato monobásico de Cálcio',
    'b': 'Água quente',
    'pResina': 'Resina',
  },
);

const sellarFieldMap = {
  'identificacao': 'talhao',
  'numeroSellar': 'numeroAmostra',
  'profundidade': 'profundidade',
  'phCaCl2': 'phCaCl2',
  'phAgua': 'phAgua',
  'phSmp': 'phSmp',
  'materiaOrganica': 'materiaOrganica',
  'carbonoOrganico': 'carbonoOrganico',
  'pMehlich': 'pMehlich',
  'pResina': 'pResina',
  'pRem': 'pRem',
  's020': 's020',
  's2040': 's2040',
  'k_mgdm3': 'k', // ImportService converte ÷ 391
  'ca': 'ca',
  'mg': 'mg',
  'al': 'al',
  'hMaisAl': 'hMaisAl',
  'na': 'na',
  'b': 'b',
  'cu': 'cu',
  'fe': 'fe',
  'mn': 'mn',
  'zn': 'zn',
  'ni': 'ni',
  'mo': 'mo',
  'se': 'se',
  'argila': 'argila',
  'silte': 'silte',
  'areiaTotal': 'areiaTotal',
};

const sellarIgnoredFields = {
  'derivados',
  'extratores',
  'laudoNumero',
  'dataEntrada',
  'dataGeracao',
};
