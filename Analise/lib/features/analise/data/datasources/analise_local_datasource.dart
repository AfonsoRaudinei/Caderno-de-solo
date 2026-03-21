import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';

class AnaliseLocalDatasource implements AnaliseDataSource {
  final List<AnaliseSoloModel> _analisesMock = [];

  final List<ProdutorModel> _produtoresMock = [
    const ProdutorModel(
        id: '1',
        nome: 'João Batista',
        fazenda: 'Fazenda Esperança',
        totalAnalises: 5),
    const ProdutorModel(
        id: '2',
        nome: 'Maria Silva',
        fazenda: 'Sítio do Sol',
        totalAnalises: 2),
    const ProdutorModel(
        id: '3',
        nome: 'Carlos Mendes',
        fazenda: 'Estância Bela Vista',
        totalAnalises: 12),
  ];

  @override
  Future<List<AnaliseSoloModel>> getAnalises() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_analisesMock);
  }

  @override
  Future<void> saveAnalise(AnaliseSoloModel analise) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index =
        _analisesMock.indexWhere((element) => element.id == analise.id);
    if (index >= 0) {
      _analisesMock[index] = analise;
    } else {
      _analisesMock.add(analise);
    }
  }

  @override
  Future<void> deleteAnalise(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _analisesMock.removeWhere((element) => element.id == id);
  }

  @override
  Future<List<ProdutorModel>> getProdutores() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_produtoresMock);
  }
}
