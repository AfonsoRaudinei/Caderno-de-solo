import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/analise/domain/value_objects/analise_hierarquia_vinculo.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';

/// Resolve e aplica vínculos hierárquicos entre análises e clientes.
class AnaliseVinculoService {
  const AnaliseVinculoService._();

  static bool _nomesCompativeis(String a, String b) {
    return ProdutorResolucaoService.nomesProdutorCompativeis(a, b);
  }

  static String _normalizar(String value) => value.trim().toLowerCase();

  static bool _textoCompativel(String a, String b) {
    final left = _normalizar(a);
    final right = _normalizar(b);
    if (left.isEmpty || right.isEmpty) return false;
    return left == right || left.contains(right) || right.contains(left);
  }

  static String _talhaoChave(AnaliseSolo analise) {
    final codigo = analise.codigoTalhao?.trim() ?? '';
    if (codigo.isNotEmpty) return codigo;
    return analise.talhao.trim();
  }

  static bool _talhaoCompativel(
    AnaliseSolo analise,
    TalhaoHierarquiaSnapshot talhao,
  ) {
    final chaveAnalise = _talhaoChave(analise);
    if (chaveAnalise.isEmpty) return false;
    return _textoCompativel(chaveAnalise, talhao.nome);
  }

  static ClienteHierarquiaSnapshot? _buscarCliente(
    AnaliseSolo analise,
    List<ClienteHierarquiaSnapshot> clientes,
  ) {
    final produtor = ProdutorResolucaoService.produtorEfetivo(analise);
    if (produtor.isEmpty) return null;

    for (final cliente in clientes) {
      if (_nomesCompativeis(produtor, cliente.nome)) {
        return cliente;
      }
    }
    return null;
  }

  static FazendaHierarquiaSnapshot? _buscarFazenda(
    AnaliseSolo analise,
    ClienteHierarquiaSnapshot cliente,
  ) {
    final nomeFazenda = analise.fazenda.trim();
    if (nomeFazenda.isEmpty) return null;

    for (final fazenda in cliente.fazendas) {
      if (_textoCompativel(nomeFazenda, fazenda.nome)) {
        return fazenda;
      }
    }
    return null;
  }

  static TalhaoHierarquiaSnapshot? _buscarTalhao(
    AnaliseSolo analise,
    FazendaHierarquiaSnapshot fazenda,
  ) {
    for (final talhao in fazenda.talhoes) {
      if (_talhaoCompativel(analise, talhao)) {
        return talhao;
      }
    }
    return null;
  }

  /// Infere vínculo por correspondência de nomes. Retorna `null` se faltar
  /// qualquer nível da hierarquia.
  static AnaliseHierarquiaVinculo? inferir({
    required AnaliseSolo analise,
    required List<ClienteHierarquiaSnapshot> clientes,
  }) {
    final cliente = _buscarCliente(analise, clientes);
    if (cliente == null) return null;

    final fazenda = _buscarFazenda(analise, cliente);
    if (fazenda == null) return null;

    final talhao = _buscarTalhao(analise, fazenda);
    if (talhao == null) return null;

    return AnaliseHierarquiaVinculo(
      clienteId: cliente.id,
      fazendaId: fazenda.id,
      talhaoId: talhao.id,
      status: AnaliseVinculoStatus.inferido,
      clienteNome: cliente.nome,
      fazendaNome: fazenda.nome,
      talhaoNome: talhao.nome,
    );
  }

  static AnaliseSolo aplicarVinculoManual({
    required AnaliseSolo analise,
    required String clienteId,
    required String fazendaId,
    required String talhaoId,
    String? clienteNome,
    String? fazendaNome,
    String? talhaoNome,
  }) {
    return aplicarVinculo(
      analise,
      AnaliseHierarquiaVinculo(
        clienteId: clienteId,
        fazendaId: fazendaId,
        talhaoId: talhaoId,
        status: AnaliseVinculoStatus.manual,
        clienteNome: clienteNome,
        fazendaNome: fazendaNome,
        talhaoNome: talhaoNome,
      ),
    );
  }

  static AnaliseSolo aplicarVinculo(
    AnaliseSolo analise,
    AnaliseHierarquiaVinculo vinculo,
  ) {
    if (!vinculo.isCompleto) return analise;

    return analise.copyWith(
      clienteId: vinculo.clienteId,
      fazendaId: vinculo.fazendaId,
      talhaoId: vinculo.talhaoId,
      vinculoStatus: vinculo.status,
      produtor: vinculo.clienteNome?.trim().isNotEmpty == true
          ? vinculo.clienteNome!.trim()
          : analise.produtor,
      fazenda: vinculo.fazendaNome?.trim().isNotEmpty == true
          ? vinculo.fazendaNome!.trim()
          : analise.fazenda,
      talhao: vinculo.talhaoNome?.trim().isNotEmpty == true
          ? vinculo.talhaoNome!.trim()
          : analise.talhao,
    );
  }

  /// Tenta inferir vínculo quando a análise ainda não possui FKs completas.
  static AnaliseSolo tentarInferirVinculo({
    required AnaliseSolo analise,
    required List<ClienteHierarquiaSnapshot> clientes,
  }) {
    if (analise.possuiVinculoHierarquico) return analise;

    final inferido = inferir(analise: analise, clientes: clientes);
    if (inferido == null) {
      if (analise.vinculoStatus == AnaliseVinculoStatus.pendente) {
        return analise;
      }
      return analise.copyWith(vinculoStatus: AnaliseVinculoStatus.pendente);
    }

    return aplicarVinculo(analise, inferido);
  }
}
