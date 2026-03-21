import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/data/datasources/local/calibracao_hive_datasource.dart';
import 'package:soloforte/data/datasources/remote/calibracao_firestore_datasource.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:uuid/uuid.dart';

final calibracaoHiveDatasourceProvider =
    Provider<CalibracaoHiveDatasource>((ref) {
  return CalibracaoHiveDatasource();
});

final calibracaoFirestoreDatasourceProvider =
    Provider<CalibracaoFirestoreDatasource>((ref) {
  return CalibracaoFirestoreDatasource(FirebaseFirestore.instance);
});

final calibracaoUsadaNaRecomendacaoProvider =
    StateProvider<String?>((ref) => null);

final calibracaoControllerProvider =
    StateNotifierProvider<CalibracaoController, CalibracaoState>((ref) {
  return CalibracaoController(
    hiveDatasource: ref.read(calibracaoHiveDatasourceProvider),
    firestoreDatasource: ref.read(calibracaoFirestoreDatasourceProvider),
    auth: FirebaseAuth.instance,
  )..load();
});

class CalibracaoState {
  const CalibracaoState({
    required this.loading,
    required this.saving,
    required this.profiles,
    required this.selectedProfileId,
    required this.draft,
    this.errorMessage,
    this.successMessage,
  });

  final bool loading;
  final bool saving;
  final List<CalibracaoProfile> profiles;
  final String? selectedProfileId;
  final CalibracaoProfile draft;
  final String? errorMessage;
  final String? successMessage;

  CalibracaoState copyWith({
    bool? loading,
    bool? saving,
    List<CalibracaoProfile>? profiles,
    String? selectedProfileId,
    bool resetSelected = false,
    CalibracaoProfile? draft,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return CalibracaoState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      profiles: profiles ?? this.profiles,
      selectedProfileId:
          resetSelected ? null : (selectedProfileId ?? this.selectedProfileId),
      draft: draft ?? this.draft,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}

class CalibracaoController extends StateNotifier<CalibracaoState> {
  CalibracaoController({
    required CalibracaoHiveDatasource hiveDatasource,
    required CalibracaoFirestoreDatasource firestoreDatasource,
    required FirebaseAuth auth,
  })  : _hiveDatasource = hiveDatasource,
        _firestoreDatasource = firestoreDatasource,
        _auth = auth,
        super(
          CalibracaoState(
            loading: true,
            saving: false,
            profiles: const [],
            selectedProfileId: null,
            draft: _novoDraft(cultura: 'Soja'),
          ),
        );

  final CalibracaoHiveDatasource _hiveDatasource;
  final CalibracaoFirestoreDatasource _firestoreDatasource;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  Future<void> load() async {
    state = state.copyWith(
      loading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    try {
      final localMaps = await _hiveDatasource.getProfiles();
      final local = localMaps.map(CalibracaoProfile.fromJson).toList();

      var merged = local;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        try {
          final remoteMaps = await _firestoreDatasource.getProfiles(userId);
          final remote = remoteMaps.map(CalibracaoProfile.fromJson).toList();
          merged = _mergeProfiles(local: local, remote: remote);
          await _persistLocal(merged);
        } catch (_) {
          // Offline/falha remota não impede fluxo local.
        }
      }

      final sorted = _sortByUpdatedDesc(merged);
      final selectedId = sorted.isNotEmpty ? sorted.first.id : null;
      state = state.copyWith(
        loading: false,
        profiles: sorted,
        selectedProfileId: selectedId,
        draft: selectedId == null
            ? _novoDraft(cultura: 'Soja')
            : sorted.first.copyWith(),
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Falha ao carregar perfis de calibração.',
      );
    }
  }

  void selecionarPerfil(String? profileId) {
    if (profileId == null) return;
    final profile = state.profiles.where((p) => p.id == profileId).firstOrNull;
    if (profile == null) return;
    state = state.copyWith(
      selectedProfileId: profileId,
      draft: profile.copyWith(),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void novo() {
    final cultura = state.draft.cultura.isEmpty ? 'Soja' : state.draft.cultura;
    state = state.copyWith(
      resetSelected: true,
      draft: _novoDraft(cultura: cultura),
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  void atualizarNome(String value) {
    _updateDraft(state.draft.copyWith(nome: value));
  }

  void atualizarCultura(String? value) {
    if (value == null || value.isEmpty) return;
    _updateDraft(
      state.draft.copyWith(
        cultura: value,
        parametrosCards: _defaultParametrosPorCultura(value),
      ),
    );
  }

  void atualizarSafra(String value) {
    _updateDraft(state.draft.copyWith(safra: value));
  }

  void atualizarCliente(String value) {
    _updateDraft(state.draft.copyWith(cliente: value));
  }

  void atualizarFazenda(String value) {
    _updateDraft(state.draft.copyWith(fazenda: value));
  }

  void atualizarTalhao(String value) {
    _updateDraft(state.draft.copyWith(talhao: value));
  }

  void atualizarObservacoes(String value) {
    _updateDraft(state.draft.copyWith(observacoes: value));
  }

  void atualizarParametrosCorretivos(Map<String, dynamic> value) {
    final parametros = Map<String, dynamic>.from(state.draft.parametrosCards);
    parametros['corretivos'] = value;
    _updateDraft(state.draft.copyWith(parametrosCards: parametros));
  }

  void atualizarParametrosFosforo(Map<String, dynamic> value) {
    final parametros = Map<String, dynamic>.from(state.draft.parametrosCards);
    parametros['fosforo'] = value;
    _updateDraft(state.draft.copyWith(parametrosCards: parametros));
  }

  void atualizarParametrosPotassio(Map<String, dynamic> value) {
    final parametros = Map<String, dynamic>.from(state.draft.parametrosCards);
    parametros['potassio'] = value;
    _updateDraft(state.draft.copyWith(parametrosCards: parametros));
  }

  void atualizarParametrosMicros(Map<String, dynamic> value) {
    final parametros = Map<String, dynamic>.from(state.draft.parametrosCards);
    parametros['micros'] = value;
    _updateDraft(state.draft.copyWith(parametrosCards: parametros));
  }

  Future<bool> salvar({bool salvarComoNovo = false}) async {
    final nome = state.draft.nome.trim();
    final cultura = state.draft.cultura.trim();
    if (nome.isEmpty) {
      state = state.copyWith(errorMessage: 'Informe o nome da calibração.');
      return false;
    }
    if (cultura.isEmpty) {
      state = state.copyWith(errorMessage: 'A cultura é obrigatória.');
      return false;
    }

    state = state.copyWith(
        saving: true, clearErrorMessage: true, clearSuccessMessage: true);
    try {
      final now = DateTime.now();
      final shouldCreate = salvarComoNovo || state.selectedProfileId == null;
      final profileId = shouldCreate ? _uuid.v4() : state.draft.id;

      final profile = state.draft.copyWith(
        id: profileId,
        nome: nome,
        cultura: cultura,
        createdAt: shouldCreate ? now : state.draft.createdAt,
        updatedAt: now,
      );

      final updated = [...state.profiles];
      final idx = updated.indexWhere((p) => p.id == profile.id);
      if (idx >= 0) {
        updated[idx] = profile;
      } else {
        updated.add(profile);
      }
      final sorted = _sortByUpdatedDesc(updated);

      await _persistLocal(sorted);
      await _syncUpsert(profile);

      state = state.copyWith(
        saving: false,
        profiles: sorted,
        selectedProfileId: profile.id,
        draft: profile,
        successMessage: shouldCreate
            ? 'Calibração salva como novo perfil.'
            : 'Calibração atualizada com sucesso.',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        saving: false,
        errorMessage: 'Não foi possível salvar a calibração.',
      );
      return false;
    }
  }

  Future<bool> duplicarSelecionado() async {
    if (state.selectedProfileId == null) {
      state =
          state.copyWith(errorMessage: 'Selecione um perfil para duplicar.');
      return false;
    }
    final base = state.profiles
        .where((p) => p.id == state.selectedProfileId)
        .firstOrNull;
    if (base == null) return false;

    _updateDraft(
      base.copyWith(
        id: '',
        nome: '${base.nome} — Cópia',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    state = state.copyWith(
        resetSelected: true, successMessage: 'Perfil duplicado no rascunho.');
    return salvar(salvarComoNovo: true);
  }

  Future<bool> excluirSelecionado() async {
    final selectedId = state.selectedProfileId;
    if (selectedId == null) {
      state = state.copyWith(errorMessage: 'Selecione um perfil para excluir.');
      return false;
    }

    try {
      final updated = state.profiles.where((p) => p.id != selectedId).toList();
      await _persistLocal(updated);
      await _syncDelete(selectedId);

      final nextSelected = updated.isNotEmpty ? updated.first : null;
      state = state.copyWith(
        profiles: updated,
        selectedProfileId: nextSelected?.id,
        draft: nextSelected?.copyWith() ?? _novoDraft(cultura: 'Soja'),
        successMessage: 'Perfil excluído.',
      );
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro ao excluir perfil.');
      return false;
    }
  }

  void limparMensagens() {
    state = state.copyWith(clearErrorMessage: true, clearSuccessMessage: true);
  }

  void _updateDraft(CalibracaoProfile draft) {
    state = state.copyWith(
      draft: draft,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  Future<void> _persistLocal(List<CalibracaoProfile> profiles) async {
    final json = profiles.map((e) => e.toJson()).toList();
    await _hiveDatasource.saveProfiles(json);
  }

  Future<void> _syncUpsert(CalibracaoProfile profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestoreDatasource.upsertProfile(userId, profile.toJson());
    } catch (_) {
      // Falha de sync remota é tolerada no fluxo offline-first.
    }
  }

  Future<void> _syncDelete(String profileId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestoreDatasource.deleteProfile(userId, profileId);
    } catch (_) {
      // Falha de sync remota é tolerada no fluxo offline-first.
    }
  }

  List<CalibracaoProfile> _mergeProfiles({
    required List<CalibracaoProfile> local,
    required List<CalibracaoProfile> remote,
  }) {
    final byId = <String, CalibracaoProfile>{};
    for (final p in [...local, ...remote]) {
      final existing = byId[p.id];
      if (existing == null || p.updatedAt.isAfter(existing.updatedAt)) {
        byId[p.id] = p;
      }
    }
    return byId.values.toList();
  }

  List<CalibracaoProfile> _sortByUpdatedDesc(List<CalibracaoProfile> list) {
    final copy = [...list];
    copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  static CalibracaoProfile _novoDraft({required String cultura}) {
    final now = DateTime.now();
    return CalibracaoProfile(
      id: '',
      nome: '',
      cultura: cultura,
      safra: '',
      cliente: '',
      fazenda: '',
      talhao: '',
      observacoes: '',
      parametrosCards: _defaultParametrosPorCultura(cultura),
      createdAt: now,
      updatedAt: now,
    );
  }

  static Map<String, dynamic> _defaultParametrosPorCultura(String cultura) {
    final alvos = _metasAlbrechtPorCultura(cultura);

    switch (cultura) {
      case 'Milho':
        return {
          'corretivos': _defaultCorretivos(cultura: cultura, alvos: alvos),
          'fosforo': defaultFosforo(),
          'potassio': defaultPotassio(cultura: cultura),
          'micros': defaultMicros(),
        };
      case 'Feijão':
        return {
          'corretivos': _defaultCorretivos(cultura: cultura, alvos: alvos),
          'fosforo': defaultFosforo(),
          'potassio': defaultPotassio(cultura: cultura),
          'micros': defaultMicros(),
        };
      case 'Algodão':
        return {
          'corretivos': _defaultCorretivos(cultura: cultura, alvos: alvos),
          'fosforo': defaultFosforo(),
          'potassio': defaultPotassio(cultura: cultura),
          'micros': defaultMicros(),
        };
      case 'Soja':
      default:
        return {
          'corretivos': _defaultCorretivos(cultura: cultura, alvos: alvos),
          'fosforo': defaultFosforo(),
          'potassio': defaultPotassio(cultura: cultura),
          'micros': defaultMicros(),
        };
    }
  }

  static Map<String, num> _metasAlbrechtPorCultura(String cultura) {
    switch (cultura) {
      case 'Feijão':
        return {'ca': 65, 'mg': 15, 'k': 5};
      case 'Algodão':
        return {'ca': 65, 'mg': 12, 'k': 5};
      case 'Milho':
      case 'Soja':
      default:
        return {'ca': 65, 'mg': 15, 'k': 4};
    }
  }

  static Map<String, dynamic> _defaultCorretivos({
    required String cultura,
    required Map<String, num> alvos,
  }) {
    return {
      'referencia': '01 — Calagem: Motor de Cálculo',
      'referenciaId': 'ref-calagem-01',
      'arquivoMarkdown': 'PROMPT/dados referencias/01_calagem.md',
      'tipoCalagem': 'Corretiva',
      'tipoCalcario': 'Dolomítico',
      'calcario1': {
        'caO': 30.0,
        'mgO': 16.0,
        'pn': 90.0,
        're': 90.0,
        'prnt': 81.0,
      },
      'usarSegundoCalcario': false,
      'calcario2': {
        'caO': 42.0,
        'mgO': 3.0,
        'pn': 88.0,
        're': 85.0,
        'prnt': 75.0,
      },
      'proporcaoCalcario1': 50.0,
      'metodoCalagem': '① Saturação por Bases (V%)',
      'v2': 70.0,
      'fatorHAl': 0.5,
      'doseFixa': 1.75,
      'mgDesejado': 0.8,
      'albrecht': {
        'cultura': cultura,
        'caAlvo': alvos['ca']!.toDouble(),
        'mgAlvo': alvos['mg']!.toDouble(),
        'kAlvo': alvos['k']!.toDouble(),
        'ncCa': 2.0,
        'ncMg': 0.8,
        'ncK': 0.15,
        'incluirNa': false,
        'naAlvo': 0.0,
      },
      'metodoIncorporacao': 'Grade aradora leve',
      'diametroGradePol': 32.0,
      'folgaMancal': 25.0,
      'profundidadeManual': 25.0,
      'sc': 0.9,
      'mesAplicacao': 'Setembro',
      'gesso': {
        'usarGesso': true,
        'metodo': '① EMBRAPA / Souza et al. (2004) — argila %',
        'teorCa': 20.0,
        'teorS': 15.0,
        'dose': 1.0,
      },
    };
  }

  static Map<String, dynamic> defaultFosforo() {
    return {
      'extrator': 'Resina (IAC)',
      'referencia': '03 — Fósforo (P): Motor de Cálculo',
      'nc': 30.0,
      'camada': '0–20 cm',
      'modoCalculo': 'Correção do solo',
      'percentualCorrecao': 100.0,
      'fatorSolo': 4.0,
      'cultivar': '',
      'tipoDadoCultivar': 'Exportação',
      'percentualUsoPSolo': 0.0,
      'doseMinimaLegacyP': 30.0,
      'modoAplicacao': 'Sulco de semeadura',
      'fepBase': 15.0,
    };
  }

  static Map<String, dynamic> defaultPotassio({String cultura = 'Soja'}) {
    final isAlgodao = cultura.toLowerCase() == 'algodão' ||
        cultura.toLowerCase() == 'algodao';
    return {
      'extrator': 'Resina (IAC)',
      'referencia': '04 — Potássio (K): Motor de Cálculo',
      'criterioNc': 'Ambos — usar o maior',
      'ncTeor': 80.0,
      'ncPctCtc': isAlgodao ? 5.0 : 4.0,
      'camada': '0–20 cm',
      'modoCalculo': 'Correção do solo',
      'percentualCorrecao': 100.0,
      'cultivar': '',
      'tipoDadoCultivar': 'Exportação',
      'percentualUsoKSolo': 0.0,
      'modoAplicacao': 'A lanço incorporado',
      'fekBase': isAlgodao ? 60.0 : 65.0,
      'doseSulco': 0.0,
    };
  }

  static Map<String, dynamic> defaultMicros() {
    Map<String, dynamic> elemento({
      required String simbolo,
      required String extrator,
      required double ncSolo,
      required String fonteSolo,
      required double teorSolo,
      required double eficienciaSolo,
      required String fonteFoliar,
      required double teorFoliar,
      required double eficienciaFoliar,
      required double doseFoliar,
    }) {
      return {
        'simbolo': simbolo,
        'extrator': extrator,
        'referencia': '06 — Micronutrientes: Motor de Cálculo',
        'ncSolo': ncSolo,
        'viaAplicacao': 'Solo (correção)',
        'percentualCorrecaoSolo': 100.0,
        'fonteSolo': fonteSolo,
        'teorFonteSolo': teorSolo,
        'eficienciaSolo': eficienciaSolo,
        'doseElementoFoliar': doseFoliar,
        'fonteFoliar': fonteFoliar,
        'teorFonteFoliar': teorFoliar,
        'eficienciaFoliar': eficienciaFoliar,
        'temAnaliseFoliar': false,
        'teorFoliar': 0.0,
        'adicionarGrupo': false,
        'grupoId': '',
      };
    }

    return {
      'pH': 5.8,
      'plantioDiretoAntigo': false,
      'gessoDoseKgHa': 0.0,
      'elementos': {
        'B': elemento(
          simbolo: 'B',
          extrator: 'Água quente',
          ncSolo: 0.36,
          fonteSolo: 'Ulexita',
          teorSolo: 10.0,
          eficienciaSolo: 60.0,
          fonteFoliar: 'Ácido bórico',
          teorFoliar: 17.0,
          eficienciaFoliar: 80.0,
          doseFoliar: 150.0,
        ),
        'Cu': elemento(
          simbolo: 'Cu',
          extrator: 'DTPA-TEA',
          ncSolo: 0.71,
          fonteSolo: 'Sulfato de cobre',
          teorSolo: 25.0,
          eficienciaSolo: 40.0,
          fonteFoliar: 'Sulfato de cobre',
          teorFoliar: 25.0,
          eficienciaFoliar: 65.0,
          doseFoliar: 150.0,
        ),
        'Fe': elemento(
          simbolo: 'Fe',
          extrator: 'DTPA-TEA',
          ncSolo: 19.0,
          fonteSolo: 'Sulfato ferroso',
          teorSolo: 20.0,
          eficienciaSolo: 30.0,
          fonteFoliar: 'EDTA-Fe',
          teorFoliar: 13.0,
          eficienciaFoliar: 85.0,
          doseFoliar: 80.0,
        ),
        'Mn': elemento(
          simbolo: 'Mn',
          extrator: 'DTPA-TEA',
          ncSolo: 6.0,
          fonteSolo: 'Sulfato de manganês',
          teorSolo: 27.0,
          eficienciaSolo: 25.0,
          fonteFoliar: 'Sulfato de manganês',
          teorFoliar: 27.0,
          eficienciaFoliar: 70.0,
          doseFoliar: 250.0,
        ),
        'Zn': elemento(
          simbolo: 'Zn',
          extrator: 'DTPA-TEA',
          ncSolo: 0.91,
          fonteSolo: 'Sulfato de zinco',
          teorSolo: 23.0,
          eficienciaSolo: 50.0,
          fonteFoliar: 'Sulfato de zinco',
          teorFoliar: 23.0,
          eficienciaFoliar: 70.0,
          doseFoliar: 200.0,
        ),
        'Mo': elemento(
          simbolo: 'Mo',
          extrator: 'Oxalato de amônio',
          ncSolo: 0.1,
          fonteSolo: 'Molibdato de sódio',
          teorSolo: 39.0,
          eficienciaSolo: 70.0,
          fonteFoliar: 'Molibdato de sódio',
          teorFoliar: 39.0,
          eficienciaFoliar: 90.0,
          doseFoliar: 40.0,
        ),
        'Co': elemento(
          simbolo: 'Co',
          extrator: 'DTPA-TEA',
          ncSolo: 0.05,
          fonteSolo: 'Sulfato de cobalto',
          teorSolo: 21.0,
          eficienciaSolo: 50.0,
          fonteFoliar: 'Sulfato de cobalto',
          teorFoliar: 21.0,
          eficienciaFoliar: 70.0,
          doseFoliar: 3.0,
        ),
        'Ni': elemento(
          simbolo: 'Ni',
          extrator: 'DTPA-TEA',
          ncSolo: 0.1,
          fonteSolo: 'Sulfato de níquel',
          teorSolo: 22.0,
          eficienciaSolo: 50.0,
          fonteFoliar: 'Sulfato de níquel',
          teorFoliar: 22.0,
          eficienciaFoliar: 70.0,
          doseFoliar: 5.0,
        ),
        'Se': elemento(
          simbolo: 'Se',
          extrator: 'DTPA-TEA',
          ncSolo: 0.05,
          fonteSolo: 'Selenato de sódio',
          teorSolo: 45.0,
          eficienciaSolo: 50.0,
          fonteFoliar: 'Selenato de sódio',
          teorFoliar: 45.0,
          eficienciaFoliar: 70.0,
          doseFoliar: 5.0,
        ),
      },
      'grupos': <Map<String, dynamic>>[],
    };
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
