# AUDITORIA PROFUNDA V2 — SoloForte
Data: 2026-04-25 09:53:56 -03

---

## RESUMO EXECUTIVO

| # | Item | Arquivo | Linha | Severidade |
|---|------|---------|-------|------------|
| 1 | invalidateSelf em salvar() | lib/features/config/presentation/providers/tabela_metricas_provider.dart | 28 | 🚨 |
| 2 | invalidateSelf em salvar() | lib/features/laboratorio/presentation/providers/laudo_provider.dart | 40 | 🚨 |
| 3 | UI importa engine diretamente | lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart | 14 | 🚨 |
| 4 | UI chama engine.calcular diretamente | lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart | 537 | 🚨 |
| 5 | Conversão ÷391 fora do parser | lib/features/analise/domain/validation/analise_data_contract.dart; lib/features/analise/presentation/widgets/analise_resultado_table.dart | 796;87 | ⚠️ |
| 6 | Conta demo sem credenciais preenchidas no pack de review | docs/release/app_store_connect_pack.md | 86-88 | 🚨 |
| 7 | state.extra em rotas LAB | lib/core/router/app_router.dart | 235;251 | ⚠️ |
| 8 | Arquivo morto confirmado (sem importadores) | lib/features/crop/presentation/widgets/crop_phenology_tracker.dart | - | 💀 |

---

## ARQUIVOS MORTOS CONFIRMADOS 💀

| Arquivo | Motivo | Importado por alguém? |
|---------|--------|----------------------|
| lib/core/services/location_service.dart | duplicado não referenciado | não |
| lib/core/utils/location_service.dart | export legado sem consumidores | não |
| lib/features/crop/presentation/widgets/crop_phenology_tracker.dart | sem uso no app | não |
| lib/domain/usecases/calcular_recomendacao_usecase.dart | sem importadores | não |

---

## ARQUIVOS MORTOS SUSPEITOS (não confirmados)

- lib/features/config/application/providers/tabela_metricas_provider.dart (fachada/export)
- lib/features/laboratorio/application/providers/laudo_provider.dart (fachada/export)
- lib/features/analise/application/providers/analise_provider.dart (fachada/export)

---

## DUPLICAÇÕES CONFIRMADAS

| Arquivo A | Arquivo B | Qual está ativo | Qual é morto |
|-----------|-----------|-----------------|--------------|
| lib/core/services/location_service.dart | lib/domain/services/location_service.dart | domain/services/location_service.dart | core/services/location_service.dart |
| lib/core/utils/location_service.dart | lib/domain/services/location_service.dart | domain/services/location_service.dart | core/utils/location_service.dart |
| config/application/providers/tabela_metricas_provider.dart | config/presentation/providers/tabela_metricas_provider.dart | presentation (implementação), application é alias | nenhum morto confirmado |
| laboratorio/application/providers/laudo_provider.dart | laboratorio/presentation/providers/laudo_provider.dart | presentation (implementação), application é alias | nenhum morto confirmado |
| analise/application/providers/analise_provider.dart | analise/presentation/providers/analise_provider.dart | presentation (implementação), application é alias | nenhum morto confirmado |

---

## CONVERSÃO K (÷391) — MAPA COMPLETO

| Arquivo | Linha | Contexto | É correto? |
|---------|-------|----------|------------|
| lib/data/lab_templates/*_import_service.dart | várias | parser/importação | ✅ |
| lib/features/analise/data/datasources/analise_local_datasource.dart | 159 | ingestão local | ⚠️ (regra duplicada) |
| lib/features/analise/domain/validation/analise_data_contract.dart | 796 | validação domínio | ⚠️ (fora de parser) |
| lib/features/analise/presentation/widgets/analise_resultado_table.dart | 87 | exibição UI | ⚠️ (fora de parser) |
| lib/domain/formulas/potassio_formula.dart | 20;68 | fórmulas domínio | ✅ (esperado) |
| lib/domain/formulas/conversoes.dart | 20 | constante central | ✅ |

Observação: o mesmo dado k_mgdm3 pode ser convertido em mais de um ponto do fluxo.

---

## BUGS POTENCIAIS

| Arquivo | Linha | Tipo | Descrição |
|---------|-------|------|-----------|
| lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart | 550-552 | NPE | force unwrap em mapa alvos['x']! |
| lib/features/analise/presentation/widgets/localizacao_captura_widget.dart | 86 | NPE | force unwrap de accuracy |
| lib/core/services/location_service.dart | 31 | catch | catch(e) sem log, retorna null |
| lib/features/analise/data/datasources/pdf_parser_datasource.dart | 14 | catch | catch(e) silencia e retorna [] |
| (comando F4) | - | context | NÃO ENCONTRADO no padrão solicitado |

---

## DATASOURCE EM PRODUÇÃO

- useAssetSeed: true apenas quando demo mode está ligado (linha 91).
- Datasource ativo: Firestore por padrão; local quando mock mode explícito fora de release.
- Firestore ativo em: debug e release (comportamento padrão), com mescla de seeds quando demo mode ON.

---

## NAVEGAÇÃO — state.extra

- Rota afetada: /lab/recomendacao e /lab/referencias/detalhes.
- Entidade passada: String (analiseId) e ReferenciaTecnica.
- Tem fallback null: sim.

---

## CONTA DEMO

- Existe modo demo: sim.
- Como ativar: toggle do DemoModeNotifier (persistido em Hive).
- Email/senha para Apple: não documentado com credenciais reais (campos preenchidos com "preencher").

---

## CODEMAGIC

- working_directory declarado: não.
- Workaround atual: scripts com "cd Analise".

---

## GOD FILES — PARA REFATORAÇÃO FUTURA

| Arquivo | Linhas | Widgets internos | Prioridade |
|---------|--------|-----------------|------------|
| lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart | 3558 | alto | Alta |
| lib/features/laboratorio/presentation/calibracao/calibracao_page.dart | 2090 | 6 | Alta |
| lib/data/culturas_data.dart | 1952 | 0 | Média |
| lib/domain/usecases/recomendacao_engine.dart | 1162 | 0 | Alta |
| lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart | 1057 | 3 | Alta |
| lib/features/analise/domain/validation/analise_data_contract.dart | 993 | 0 | Média |
| lib/features/auth/presentation/login/login_page.dart | 967 | alto | Média |
| lib/data/lab_templates/lab_pdf_parser.dart | 960 | 0 | Média |
| lib/features/config/presentation/config_page.dart | 905 | alto | Média |

---

## PRÓXIMOS PASSOS RECOMENDADOS (ordenados por impacto)

1. 🚨 Remover invalidateSelf() de salvar() nos providers críticos e atualizar estado explicitamente.
2. 🚨 Tirar RecomendacaoEngine da UI e mover cálculo para provider/usecase.
3. 🚨 Criar e documentar credenciais reais de conta demo para Apple Review.
4. ⚠️ Centralizar conversão de K (÷391) em um único ponto canônico.
5. ⚠️ Remover arquivos mortos confirmados e reduzir providers fachada.
6. ⚠️ Definir working_directory no Codemagic.
7. ⚠️ Planejar refatoração dos God files (absorcao_nutrientes e calibracao_page).

---

## EVIDÊNCIAS (COMANDOS + OUTPUT REAL)

### A.1 arquivo 1
Comando:
```bash
cat -n "Analise/lib/features/config/application/providers/tabela_metricas_provider.dart"
```
Output real:
```
     1	export 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart'
     2	    show tabelaMetricasProvider;
```

### A.1 arquivo 2
Comando:
```bash
cat -n "Analise/lib/features/laboratorio/application/providers/laudo_provider.dart"
```
Output real:
```
     1	export 'package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart'
     2	    show laudoNotifierProvider;
```

### A.1 contexto real invalidateSelf (tabela_metricas presentation)
Comando:
```bash
sed -n '22,32p' Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart
```
Output real:
```
  }

  Future<void> salvar(TabelaMetricas tabela) async {
    await ref
        .read(tabelaMetricasHiveDatasourceProvider)
        .salvarTabela(tabela);
    ref.invalidateSelf();
  }

  Future<void> resetarParaDefaults() async {
    await ref
```

### A.1 contexto real invalidateSelf (laudo presentation)
Comando:
```bash
sed -n '34,44p' Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart
```
Output real:
```
    return ref.read(laudoRepositoryProvider).getLaudos();
  }

  /// Persiste o laudo e recarrega o estado.
  Future<void> salvar(LaudoRecomendacao laudo) async {
    await ref.read(laudoRepositoryProvider).saveLaudo(laudo);
    ref.invalidateSelf();
  }

  /// Remove o laudo e recarrega o estado.
  Future<void> deletar(String id) async {
```

### A.2 head recomendacao_screen
Comando:
```bash
cat -n "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart" | head -30
```
Output real:
```
     1	import 'package:flutter/material.dart';
     2	import 'package:flutter_riverpod/flutter_riverpod.dart';
     3	import 'package:go_router/go_router.dart';
     4	import 'package:intl/intl.dart';
     5	import 'package:soloforte/core/theme/app_colors.dart';
     6	import 'package:soloforte/core/theme/app_text_styles.dart';
     7	import 'package:soloforte/core/widgets/app_button.dart';
     8	import 'package:soloforte/core/widgets/app_card.dart';
     9	import 'package:soloforte/core/widgets/app_dropdown.dart';
    10	import 'package:soloforte/core/services/app_observability.dart';
    11	import 'package:soloforte/core/constants/app_routes.dart';
    12	import 'package:soloforte/domain/entities/analise_entity.dart';
    13	import 'package:soloforte/domain/models/calibracao_profile.dart';
    14	import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
    15	import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
    16	import 'package:soloforte/features/laboratorio/services/laudo_pdf_generator.dart';
    17	import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
    18	import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
    19	import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart';
    20	import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
    21	import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
    22	import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
    23	import 'package:firebase_auth/firebase_auth.dart';
    24	import 'package:uuid/uuid.dart';
    25	
    26	class RecomendacaoScreen extends ConsumerStatefulWidget {
    27	  final String? analiseId;
    28	  const RecomendacaoScreen({super.key, this.analiseId});
    29	
    30	  @override
```

### A.2 imports recomendacao_screen
Comando:
```bash
grep -n "import" "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart"
```
Output real:
```
1:import 'package:flutter/material.dart';
2:import 'package:flutter_riverpod/flutter_riverpod.dart';
3:import 'package:go_router/go_router.dart';
4:import 'package:intl/intl.dart';
5:import 'package:soloforte/core/theme/app_colors.dart';
6:import 'package:soloforte/core/theme/app_text_styles.dart';
7:import 'package:soloforte/core/widgets/app_button.dart';
8:import 'package:soloforte/core/widgets/app_card.dart';
9:import 'package:soloforte/core/widgets/app_dropdown.dart';
10:import 'package:soloforte/core/services/app_observability.dart';
11:import 'package:soloforte/core/constants/app_routes.dart';
12:import 'package:soloforte/domain/entities/analise_entity.dart';
13:import 'package:soloforte/domain/models/calibracao_profile.dart';
14:import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
15:import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
16:import 'package:soloforte/features/laboratorio/services/laudo_pdf_generator.dart';
17:import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
18:import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
19:import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart';
20:import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
21:import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
22:import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
23:import 'package:firebase_auth/firebase_auth.dart';
24:import 'package:uuid/uuid.dart';
```

### A.2 tamanho recomendacao_screen
Comando:
```bash
wc -l "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart"
```
Output real:
```
     767 Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
```

### A.2 busca engine/calcular
Comando:
```bash
grep -n "recomendacao_engine\|CalcarioInput\|GessoInput\|FosforoInput\|calcular" "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart"
```
Output real:
```
14:import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
537:          return engine.calcular(
```

### A.2 contexto da chamada direta
Comando:
```bash
sed -n '520,550p' Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
```
Output real:
```
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Future<void> _gerar({
    required _AnaliseOption analiseSelecionada,
    required CalibracaoProfile perfilSelecionado,
    required List<Map<String, dynamic>> tabelas,
  }) async {
    setState(() => _gerando = true);
    try {
      final resultado = await AppObservability.instance.trace(
        'recomendacao_generate',
        () async {
          const engine = RecomendacaoEngine();
          return engine.calcular(
            analise: analiseSelecionada.entity,
            labelAnalise: analiseSelecionada.label,
            calibracao: perfilSelecionado,
            tabelas: tabelas,
          );
        },
        attributes: {'flow': 'recomendacao', 'action': 'gerar'},
      );
      ref.read(calibracaoUsadaNaRecomendacaoProvider.notifier).state =
          perfilSelecionado.id;
      setState(() {
        _resultado = resultado;
      });
```

### B.1 core/services/location_service.dart
Comando:
```bash
cat -n "Analise/lib/core/services/location_service.dart"
```
Output real:
```
     1	import 'package:geolocator/geolocator.dart';
     2	
     3	class LocationService {
     4	  Future<({double latitude, double longitude})?> getCurrentLocation() async {
     5	    try {
     6	      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
     7	      if (!serviceEnabled) {
     8	        return null;
     9	      }
    10	
    11	      LocationPermission permission = await Geolocator.checkPermission();
    12	      if (permission == LocationPermission.denied) {
    13	        permission = await Geolocator.requestPermission();
    14	        if (permission == LocationPermission.denied) {
    15	          return null;
    16	        }
    17	      }
    18	
    19	      if (permission == LocationPermission.deniedForever) {
    20	        return null;
    21	      }
    22	
    23	      final position = await Geolocator.getCurrentPosition(
    24	        desiredAccuracy: LocationAccuracy.high,
    25	      );
    26	      
    27	      return (
    28	        latitude: double.parse(position.latitude.toStringAsFixed(8)),
    29	        longitude: double.parse(position.longitude.toStringAsFixed(8)),
    30	      );
    31	    } catch (e) {
    32	      return null;
    33	    }
    34	  }
    35	}
```

### B.1 core/utils/location_service.dart
Comando:
```bash
cat -n "Analise/lib/core/utils/location_service.dart"
```
Output real:
```
     1	export 'package:soloforte/domain/services/location_service.dart';
```

### B.1 domain/services/location_service.dart
Comando:
```bash
cat -n "Analise/lib/domain/services/location_service.dart"
```
Output real:
```
     1	import 'package:geocoding/geocoding.dart';
     2	import 'package:geolocator/geolocator.dart';
     3	
     4	/// Resultado da captura de localização.
     5	class LocationResult {
     6	  final double latitude;
     7	  final double longitude;
     8	  final double? accuracy;
     9	  final String? cidade;
    10	  final String? estado;
    11	  final String? pais;
    12	
    13	  const LocationResult({
    14	    required this.latitude,
    15	    required this.longitude,
    16	    this.accuracy,
    17	    this.cidade,
    18	    this.estado,
    19	    this.pais,
    20	  });
    21	
    22	  String get coordenadasFormatadas =>
    23	      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    24	
    25	  String get enderecoResumido {
    26	    final partes = [cidade, estado, pais].whereType<String>().toList();
    27	    return partes.isNotEmpty ? partes.join(', ') : coordenadasFormatadas;
    28	  }
    29	}
    30	
    31	abstract class LocationService {
    32	  Future<LocationResult> capturar();
    33	}
    34	
    35	class LocationServiceImpl implements LocationService {
    36	  @override
    37	  Future<LocationResult> capturar() async {
    38	    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    39	    if (!serviceEnabled) {
    40	      throw const LocationException(
    41	        'GPS desativado. Ative a localização nas configurações do dispositivo.',
    42	      );
    43	    }
    44	
    45	    LocationPermission permission = await Geolocator.checkPermission();
    46	    if (permission == LocationPermission.denied) {
    47	      permission = await Geolocator.requestPermission();
    48	      if (permission == LocationPermission.denied) {
    49	        throw const LocationException(
    50	          'Permissão de localização negada. Permita o acesso nas configurações do app.',
    51	        );
    52	      }
    53	    }
    54	    if (permission == LocationPermission.deniedForever) {
    55	      throw const LocationException(
    56	        'Localização bloqueada permanentemente. Habilite em Configurações > SoloForte > Localização.',
    57	      );
    58	    }
    59	
    60	    final position = await Geolocator.getCurrentPosition(
    61	      desiredAccuracy: LocationAccuracy.high,
    62	      timeLimit: const Duration(seconds: 15),
    63	    );
    64	
    65	    String? cidade, estado, pais;
    66	    try {
    67	      final placemarks = await placemarkFromCoordinates(
    68	        position.latitude,
    69	        position.longitude,
    70	      );
    71	      if (placemarks.isNotEmpty) {
    72	        final p = placemarks.first;
    73	        cidade = p.subAdministrativeArea ?? p.locality;
    74	        estado = p.administrativeArea;
    75	        pais = p.country;
    76	      }
    77	    } catch (_) {
    78	      // Geocodificação é opcional; retorna coordenadas mesmo sem endereço.
    79	    }
    80	
    81	    return LocationResult(
    82	      latitude: position.latitude,
    83	      longitude: position.longitude,
    84	      accuracy: position.accuracy,
    85	      cidade: cidade,
    86	      estado: estado,
    87	      pais: pais,
    88	    );
    89	  }
    90	}
    91	
    92	class LocationException implements Exception {
    93	  final String message;
    94	  const LocationException(this.message);
    95	
    96	  @override
    97	  String toString() => message;
    98	}
```

### B.1 imports location_service
Comando:
```bash
grep -rn "location_service" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/features/analise/presentation/providers/location_provider.dart:2:import 'package:soloforte/domain/services/location_service.dart';
Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart:3:import 'package:soloforte/domain/services/location_service.dart';
Analise/lib/features/analise/presentation/controllers/analise_controller.dart:2:import 'package:soloforte/domain/services/location_service.dart';
Analise/lib/features/analise/presentation/widgets/localizacao_captura_widget.dart:6:import 'package:soloforte/domain/services/location_service.dart';
```

### B.1 extra imports core/services path
Comando:
```bash
grep -rn "package:soloforte/core/services/location_service.dart" Analise/lib --include="*.dart"
```
Output real:
```
NÃO ENCONTRADO
```

### B.1 extra imports core/utils path
Comando:
```bash
grep -rn "package:soloforte/core/utils/location_service.dart" Analise/lib --include="*.dart"
```
Output real:
```
NÃO ENCONTRADO
```

### B.2 tabela provider application
Comando:
```bash
cat -n "Analise/lib/features/config/application/providers/tabela_metricas_provider.dart"
```
Output real:
```
     1	export 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart'
     2	    show tabelaMetricasProvider;
```

### B.2 tabela provider presentation
Comando:
```bash
cat -n "Analise/lib/features/config/presentation/providers/tabela_metricas_provider.dart"
```
Output real:
```
     1	import 'package:flutter_riverpod/flutter_riverpod.dart';
     2	import 'package:soloforte/features/config/data/datasources/tabela_metricas_hive_datasource.dart';
     3	import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
     4	import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';
     5	
     6	// ── Datasource ────────────────────────────────────────────────────────────────
     7	
     8	final tabelaMetricasHiveDatasourceProvider =
     9	    Provider<TabelaMetricasHiveDatasource>((ref) {
    10	  return TabelaMetricasHiveDatasource();
    11	});
    12	
    13	// ── Notifier ──────────────────────────────────────────────────────────────────
    14	
    15	class TabelaMetricasNotifier
    16	    extends AsyncNotifier<List<TabelaMetricas>> {
    17	  @override
    18	  Future<List<TabelaMetricas>> build() async {
    19	    return ref
    20	        .read(tabelaMetricasHiveDatasourceProvider)
    21	        .getTabelasOuSeed();
    22	  }
    23	
    24	  Future<void> salvar(TabelaMetricas tabela) async {
    25	    await ref
    26	        .read(tabelaMetricasHiveDatasourceProvider)
    27	        .salvarTabela(tabela);
    28	    ref.invalidateSelf();
    29	  }
    30	
    31	  Future<void> resetarParaDefaults() async {
    32	    await ref
    33	        .read(tabelaMetricasHiveDatasourceProvider)
    34	        .resetarParaDefaults();
    35	    ref.invalidateSelf();
    36	  }
    37	}
    38	
    39	final tabelaMetricasProvider = AsyncNotifierProvider<
    40	    TabelaMetricasNotifier, List<TabelaMetricas>>(
    41	  TabelaMetricasNotifier.new,
    42	);
    43	
    44	// ── Seletor por chave (uso nos motores) ──────────────────────────────────────
    45	
    46	/// Retorna uma [TabelaMetricas] pela [chave] canônica.
    47	/// Fallback transparente para os defaults hardcoded quando o estado
    48	/// ainda está carregando ou quando a chave não existe.
    49	TabelaMetricas tabelaPorChave(
    50	  List<TabelaMetricas> tabelas,
    51	  String chave,
    52	) {
    53	  return tabelas.firstWhere(
    54	    (t) => t.chave == chave,
    55	    orElse: () => TabelaMetricasDefaults.build()
    56	        .firstWhere((d) => d.chave == chave,
    57	            orElse: () => _tabelaVazia(chave)),
    58	  );
    59	}
    60	
    61	TabelaMetricas _tabelaVazia(String chave) => TabelaMetricas(
    62	      id: '',
    63	      chave: chave,
    64	      nome: chave,
    65	      descricao: '',
    66	      unidade: '',
    67	      linhas: const [],
    68	      updatedAt: DateTime.now(),
    69	    );
    70	
    71	// ── Helpers para os motores ───────────────────────────────────────────────────
    72	
    73	/// Calcula NC de Fósforo baseado na [referencia] e [faixaArgila].
    74	/// Aceita a lista de tabelas injetadas via Provider.
    75	double ncFosforoPorReferencia({
    76	  required String referencia,
    77	  required double argilaPercent,
    78	  required List<TabelaMetricas> tabelas,
    79	  double fallback = 8.0,
    80	}) {
    81	  String chave;
    82	  switch (referencia) {
    83	    case 'IAC Bol.100':
    84	      chave = TabelaMetricasDefaults.kFosforoNcResina;
    85	      break;
    86	    case 'Embrapa Cerrado':
    87	      chave = TabelaMetricasDefaults.kFosforoNcCerrado;
    88	      break;
    89	    case 'Embrapa RS/SC':
    90	      chave = TabelaMetricasDefaults.kFosforoNcRsSc;
    91	      break;
    92	    case 'UFLA / CFSEMG':
    93	      chave = TabelaMetricasDefaults.kFosforoNcUfla;
    94	      break;
    95	    default:
    96	      return fallback;
    97	  }
    98	  return tabelaPorChave(tabelas, chave)
    99	      .valorParaArgila(argilaPercent, fallback: fallback);
   100	}
   101	
   102	/// Nível Crítico de Fósforo — Resina (IAC).
   103	double ncFosforoResina({
   104	  required double argilaPercent,
   105	  required List<TabelaMetricas> tabelas,
   106	}) {
   107	  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoNcResina)
   108	      .valorParaArgila(argilaPercent, fallback: 30.0);
   109	}
   110	
   111	/// FEP base para o solo.
   112	double fepBaseTabela({
   113	  required double argilaPercent,
   114	  required List<TabelaMetricas> tabelas,
   115	}) {
   116	  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFep)
   117	      .valorParaArgila(argilaPercent, fallback: 15.0);
   118	}
   119	
   120	/// Fator Solo para Fósforo.
   121	double fatorSoloTabela({
   122	  required double argilaPercent,
   123	  required List<TabelaMetricas> tabelas,
   124	}) {
   125	  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFatorSolo)
   126	      .valorParaArgila(argilaPercent, fallback: 4.0);
   127	}
   128	
   129	/// NC Potássio — Teor Absoluto.
   130	double ncPotassioTeorTabela({
   131	  required double argilaPercent,
   132	  required List<TabelaMetricas> tabelas,
   133	}) {
   134	  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioNcTeor)
   135	      .valorParaArgila(argilaPercent, fallback: 80.0);
   136	}
   137	
   138	/// FEK base para o solo.
   139	double fekBaseTabela({
   140	  required double argilaPercent,
   141	  required List<TabelaMetricas> tabelas,
   142	}) {
   143	  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioFek)
   144	      .valorParaArgila(argilaPercent, fallback: 65.0);
   145	}
   146	
   147	/// Limites de antagonismo do Potássio (K% CTC, K:Mg, K:Ca).
   148	({double limiteKCtc, double limiteKMg, double limiteKCa})
   149	    antagonismosTabela(List<TabelaMetricas> tabelas) {
   150	  final tab =
   151	      tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioAntagonismos);
   152	
   153	  double buscarChaveValor(String chaveValor, double fallback) {
   154	    for (final linha in tab.linhas) {
   155	      if (linha['chaveValor'] == chaveValor) {
   156	        final v = linha['valor'];
   157	        if (v is num) return v.toDouble();
   158	      }
   159	    }
   160	    return fallback;
   161	  }
   162	
   163	  return (
   164	    limiteKCtc: buscarChaveValor('limite_k_ctc', 7.0),
   165	    limiteKMg: buscarChaveValor('limite_k_mg', 1.0),
   166	    limiteKCa: buscarChaveValor('limite_k_ca', 0.4),
   167	  );
   168	}
   169	
   170	/// Metas Albrecht dinâmicas.
   171	({double pctCa, double pctMg, double pctK}) metasAlbrechtTabela(
   172	    List<TabelaMetricas> tabelas) {
   173	  final tab =
   174	      tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemMetasAlbrecht);
   175	
   176	  double buscar(String chave, double fallback) {
   177	    for (final linha in tab.linhas) {
   178	      if (linha['chaveValor'] == chave) {
   179	        final v = linha['valor'];
   180	        if (v is num) return v.toDouble();
   181	      }
   182	    }
   183	    return fallback;
   184	  }
   185	
   186	  return (
   187	    pctCa: buscar('pct_ca', 65.0),
   188	    pctMg: buscar('pct_mg', 15.0),
   189	    pctK: buscar('pct_k', 4.0),
   190	  );
   191	}
   192	
   193	/// Valor SMP da tabela baseada no pH atual.
   194	double ncSmpTabela({
   195	  required double phSmp,
   196	  required List<TabelaMetricas> tabelas,
   197	}) {
   198	  final tab = tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemSmp);
   199	  for (final linha in tab.linhas) {
   200	    final min = (linha['phMin'] as num?)?.toDouble() ?? 0.0;
   201	    final max = (linha['phMax'] as num?)?.toDouble() ?? 9.9;
   202	    if (phSmp >= min && phSmp < max) {
   203	      final v = linha['valor'];
   204	      if (v is num) return v.toDouble();
   205	    }
   206	  }
   207	  return 0.0;
   208	}
   209	
```

### B.2 imports tabela_metricas_provider
Comando:
```bash
grep -rn "tabela_metricas_provider" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/features/config/presentation/tabela_metricas_page.dart:9:import 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart';
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:20:import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
```

### B.2 extra imports path application
Comando:
```bash
grep -rn "package:soloforte/features/config/application/providers/tabela_metricas_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:20:import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
```

### B.2 extra imports path presentation
Comando:
```bash
grep -rn "package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/config/application/providers/tabela_metricas_provider.dart:1:export 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart'
Analise/lib/features/config/presentation/tabela_metricas_page.dart:9:import 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart';
```

### B.3 imports laudo_provider
Comando:
```bash
grep -rn "laudo_provider" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/features/historico/presentation/historico_page.dart:11:import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:22:import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
```

### B.3 laudo provider application
Comando:
```bash
cat -n "Analise/lib/features/laboratorio/application/providers/laudo_provider.dart"
```
Output real:
```
     1	export 'package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart'
     2	    show laudoNotifierProvider;
```

### B.3 laudo provider presentation
Comando:
```bash
cat -n "Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart"
```
Output real:
```
     1	import 'package:firebase_auth/firebase_auth.dart';
     2	import 'package:flutter_riverpod/flutter_riverpod.dart';
     3	import 'package:soloforte/features/laboratorio/data/datasources/laudo_firestore_datasource.dart';
     4	import 'package:soloforte/features/laboratorio/data/datasources/laudo_hive_datasource.dart';
     5	import 'package:soloforte/features/laboratorio/data/repositories/laudo_repository_impl.dart';
     6	import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
     7	import 'package:soloforte/features/laboratorio/domain/repositories/laudo_repository.dart';
     8	
     9	// ── Datasources ─────────────────────────────────────────────────────────────
    10	
    11	final laudoHiveDatasourceProvider = Provider<LaudoHiveDatasource>((ref) {
    12	  return LaudoHiveDatasource();
    13	});
    14	
    15	final laudoFirestoreDatasourceProvider =
    16	    Provider<LaudoFirestoreDatasource>((ref) {
    17	  return LaudoFirestoreDatasource();
    18	});
    19	
    20	// ── Repository ───────────────────────────────────────────────────────────────
    21	
    22	final laudoRepositoryProvider = Provider<LaudoRepository>((ref) {
    23	  return LaudoRepositoryImpl(
    24	    hiveDatasource: ref.watch(laudoHiveDatasourceProvider),
    25	    firestoreDatasource: ref.watch(laudoFirestoreDatasourceProvider),
    26	  );
    27	});
    28	
    29	// ── Notifier (State) ─────────────────────────────────────────────────────────
    30	
    31	class LaudoNotifier extends AsyncNotifier<List<LaudoRecomendacao>> {
    32	  @override
    33	  Future<List<LaudoRecomendacao>> build() async {
    34	    return ref.read(laudoRepositoryProvider).getLaudos();
    35	  }
    36	
    37	  /// Persiste o laudo e recarrega o estado.
    38	  Future<void> salvar(LaudoRecomendacao laudo) async {
    39	    await ref.read(laudoRepositoryProvider).saveLaudo(laudo);
    40	    ref.invalidateSelf();
    41	  }
    42	
    43	  /// Remove o laudo e recarrega o estado.
    44	  Future<void> deletar(String id) async {
    45	    await ref.read(laudoRepositoryProvider).deleteLaudo(id);
    46	    ref.invalidateSelf();
    47	  }
    48	}
    49	
    50	final laudoNotifierProvider =
    51	    AsyncNotifierProvider<LaudoNotifier, List<LaudoRecomendacao>>(
    52	  LaudoNotifier.new,
    53	);
    54	
    55	// ── Helper: userId atual ─────────────────────────────────────────────────────
    56	
    57	/// Retorna o uid do usuário autenticado ou string vazia.
    58	String currentUserId() =>
    59	    FirebaseAuth.instance.currentUser?.uid ?? '';
```

### B.3 extra imports path application
Comando:
```bash
grep -rn "package:soloforte/features/laboratorio/application/providers/laudo_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/historico/presentation/historico_page.dart:11:import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:22:import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
```

### B.3 extra imports path presentation
Comando:
```bash
grep -rn "package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/laboratorio/application/providers/laudo_provider.dart:1:export 'package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart'
```

### B.4 imports analise_provider
Comando:
```bash
grep -rn "analise_provider" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/core/router/app_router.dart:21:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:8:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:8:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart:11:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/mapa/providers/mapa_analise_provider.dart:4:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/mapa/presentation/mapa_page.dart:8:import 'package:soloforte/features/mapa/providers/mapa_analise_provider.dart';
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:17:import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
```

### B.4 wc analise_provider application
Comando:
```bash
wc -l "Analise/lib/features/analise/application/providers/analise_provider.dart"
```
Output real:
```
       2 Analise/lib/features/analise/application/providers/analise_provider.dart
```

### B.4 wc analise_provider presentation
Comando:
```bash
wc -l "Analise/lib/features/analise/presentation/providers/analise_provider.dart"
```
Output real:
```
     152 Analise/lib/features/analise/presentation/providers/analise_provider.dart
```

### B.4 extra imports path application
Comando:
```bash
grep -rn "package:soloforte/features/analise/application/providers/analise_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:17:import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
```

### B.4 extra imports path presentation
Comando:
```bash
grep -rn "package:soloforte/features/analise/presentation/providers/analise_provider.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/core/router/app_router.dart:21:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/application/providers/analise_provider.dart:1:export 'package:soloforte/features/analise/presentation/providers/analise_provider.dart'
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:8:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:8:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart:11:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
Analise/lib/features/mapa/providers/mapa_analise_provider.dart:4:import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
```

### B.5 estrutura antiga lib/data
Comando:
```bash
find Analise/lib/data -name "*.dart" | sort
```
Output real:
```
Analise/lib/data/base_dados/nc_por_referencia.dart
Analise/lib/data/base_dados/referencias_tecnicas_data.dart
Analise/lib/data/culturas_data.dart
Analise/lib/data/datasources/local/calibracao_hive_datasource.dart
Analise/lib/data/datasources/local/calibracao_mock_db.dart
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart
Analise/lib/data/datasources/remote/auth_datasource.dart
Analise/lib/data/datasources/remote/calibracao_firestore_datasource.dart
Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart
Analise/lib/data/lab_templates/exata_brasil_import_service.dart
Analise/lib/data/lab_templates/exata_brasil_template.dart
Analise/lib/data/lab_templates/ibra_import_service.dart
Analise/lib/data/lab_templates/ibra_template.dart
Analise/lib/data/lab_templates/lab_detector.dart
Analise/lib/data/lab_templates/lab_pdf_parser.dart
Analise/lib/data/lab_templates/mb_import_service.dart
Analise/lib/data/lab_templates/mb_template.dart
Analise/lib/data/lab_templates/pdf_import_service.dart
Analise/lib/data/lab_templates/pdf_text_extractor.dart
Analise/lib/data/lab_templates/sellar_import_service.dart
Analise/lib/data/lab_templates/sellar_template.dart
Analise/lib/data/repositories/auth_repository_impl.dart
```

### B.5 estrutura nova features/analise/data
Comando:
```bash
find "Analise/lib/features/analise/data" -name "*.dart" | sort
```
Output real:
```
Analise/lib/features/analise/data/datasources/analise_datasource.dart
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart
Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart
Analise/lib/features/analise/data/models/analise_solo_model.dart
Analise/lib/features/analise/data/models/lab_template_model.dart
Analise/lib/features/analise/data/models/produtor_model.dart
Analise/lib/features/analise/data/repositories/analise_repository_impl.dart
```

### B.5 imports lib/data/datasources
Comando:
```bash
grep -rn "lib/data/datasources" Analise/lib --include="*.dart" | grep "import" | head -20
```
Output real:
```
NÃO ENCONTRADO
```

### B.5 imports lib/data/repositories
Comando:
```bash
grep -rn "lib/data/repositories" Analise/lib --include="*.dart" | grep "import" | head -10
```
Output real:
```
NÃO ENCONTRADO
```

### B.5 imports lib/domain/entities/analise_entity
Comando:
```bash
grep -rn "lib/domain/entities/analise_entity" Analise/lib --include="*.dart" | grep "import" | head -10
```
Output real:
```
NÃO ENCONTRADO
```

### B.5 imports lib/domain/models/analise_model
Comando:
```bash
grep -rn "lib/domain/models/analise_model" Analise/lib --include="*.dart" | grep "import" | head -10
```
Output real:
```
NÃO ENCONTRADO
```

### B.5 extra package imports data/datasources
Comando:
```bash
grep -rn "package:soloforte/data/datasources" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/analise/presentation/providers/analise_provider.dart:4:import 'package:soloforte/data/datasources/remote/analise_firestore_datasource.dart';
Analise/lib/features/config/presentation/config_controller.dart:4:import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
Analise/lib/features/auth/presentation/cadastro/cadastro_controller.dart:4:import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:4:import 'package:soloforte/data/datasources/local/calibracao_hive_datasource.dart';
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:5:import 'package:soloforte/data/datasources/remote/calibracao_firestore_datasource.dart';
Analise/lib/data/repositories/auth_repository_impl.dart:2:import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
```

### B.5 extra package imports data/repositories
Comando:
```bash
grep -rn "package:soloforte/data/repositories" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_controller.dart:4:import 'package:soloforte/data/repositories/auth_repository_impl.dart';
Analise/lib/features/auth/presentation/login/login_controller.dart:2:import 'package:soloforte/data/repositories/auth_repository_impl.dart';
```

### B.5 extra package imports domain/entities/analise_entity
Comando:
```bash
grep -rn "package:soloforte/domain/entities/analise_entity.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_provider.dart:2:import 'package:soloforte/domain/entities/analise_entity.dart';
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:12:import 'package:soloforte/domain/entities/analise_entity.dart';
Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart:2:import 'package:soloforte/domain/entities/analise_entity.dart';
Analise/lib/domain/usecases/recomendacao_engine.dart:10:import 'package:soloforte/domain/entities/analise_entity.dart';
```

### B.5 extra package imports domain/models/analise_model
Comando:
```bash
grep -rn "package:soloforte/domain/models/analise_model.dart" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart:9:import 'package:soloforte/domain/models/analise_model.dart';
Analise/lib/domain/formulas/fosforo_formula.dart:1:import 'package:soloforte/domain/models/analise_model.dart';
```

### B.6 files features/lab
Comando:
```bash
find "Analise/lib/features/lab" -name "*.dart" | sort
```
Output real:
```
Analise/lib/features/lab/calibracao/data/calibracao_padrao.dart
```

### B.6 files features/laboratorio
Comando:
```bash
find "Analise/lib/features/laboratorio" -name "*.dart" | sort
```
Output real:
```
Analise/lib/features/laboratorio/application/providers/laudo_provider.dart
Analise/lib/features/laboratorio/data/datasources/laudo_firestore_datasource.dart
Analise/lib/features/laboratorio/data/datasources/laudo_hive_datasource.dart
Analise/lib/features/laboratorio/data/models/laudo_recomendacao_model.dart
Analise/lib/features/laboratorio/data/repositories/laudo_repository_impl.dart
Analise/lib/features/laboratorio/domain/entities/laudo_recomendacao.dart
Analise/lib/features/laboratorio/domain/repositories/laudo_repository.dart
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.dart
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_state.freezed.dart
Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart
Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart
Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
Analise/lib/features/laboratorio/presentation/lab_page.dart
Analise/lib/features/laboratorio/presentation/providers/laudo_provider.dart
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_provider.dart
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart
Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
Analise/lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart
Analise/lib/features/laboratorio/services/laudo_pdf_generator.dart
```

### B.6 imports features/lab/
Comando:
```bash
grep -rn "features/lab/" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:8:import 'package:soloforte/features/lab/calibracao/data/calibracao_padrao.dart';
```

### B.7 crop_phenology_tracker arquivo
Comando:
```bash
cat -n "Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart"
```
Output real:
```
     1	import 'package:flutter/material.dart';
     2	
     3	/// Enumeração para os estágios fenológicos da soja
     4	enum SojaStage {
     5	  ve('VE - Emergência'),
     6	  v1('V1 - Primeiro nó'),
     7	  v2('V2 - Segundo nó'),
     8	  v3('V3 - Terceiro nó'),
     9	  vn('Vn - Enésimo nó'),
    10	  r1('R1 - Início do florescimento'),
    11	  r2('R2 - Florescimento pleno'),
    12	  r3('R3 - Início do desenvolvimento de vagem'),
    13	  r4('R4 - Vagem plena'),
    14	  r5('R5 - Início do enchimento de grãos'),
    15	  r6('R6 - Grão cheio'),
    16	  r7('R7 - Início da maturação'),
    17	  r8('R8 - Maturação plena');
    18	
    19	  final String label;
    20	  const SojaStage(this.label);
    21	}
    22	
    23	class CropPhenologyTracker extends StatefulWidget {
    24	  const CropPhenologyTracker({super.key});
    25	
    26	  @override
    27	  State<CropPhenologyTracker> createState() => _CropPhenologyTrackerState();
    28	}
    29	
    30	class _CropPhenologyTrackerState extends State<CropPhenologyTracker> {
    31	  final _formKey = GlobalKey<FormState>();
    32	  
    33	  // Controladores para os campos numéricos
    34	  final _nBalanceController = TextEditingController();
    35	  final _soilPHController = TextEditingController();
    36	  
    37	  // Estado para o estágio da soja
    38	  SojaStage? _selectedStage;
    39	
    40	  @override
    41	  void dispose() {
    42	    _nBalanceController.dispose();
    43	    _soilPHController.dispose();
    44	    super.dispose();
    45	  }
    46	
    47	  void _calcularAdubo() {
    48	    if (_formKey.currentState!.validate()) {
    49	      // Lógica de cálculo (exemplo simplificado)
    50	      final nBalance = double.tryParse(_nBalanceController.text) ?? 0.0;
    51	      final ph = double.tryParse(_soilPHController.text) ?? 0.0;
    52	      
    53	      ScaffoldMessenger.of(context).showSnackBar(
    54	        SnackBar(
    55	          content: Text(
    56	            'Calculando para ${_selectedStage?.label}...\n'
    57	            'Balanço N: $nBalance, pH: $ph',
    58	          ),
    59	          backgroundColor: Theme.of(context).colorScheme.primary,
    60	        ),
    61	      );
    62	    }
    63	  }
    64	
    65	  @override
    66	  Widget build(BuildContext context) {
    67	    return Scaffold(
    68	      appBar: AppBar(
    69	        title: const Text('Rastreador Fenológico'),
    70	        centerTitle: true,
    71	      ),
    72	      body: SingleChildScrollView(
    73	        padding: const EdgeInsets.all(24.0),
    74	        child: Form(
    75	          key: _formKey,
    76	          child: Column(
    77	            crossAxisAlignment: CrossAxisAlignment.stretch,
    78	            children: [
    79	              Text(
    80	                'Acompanhamento de Safra',
    81	                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    82	                      fontWeight: FontWeight.bold,
    83	                      color: Theme.of(context).colorScheme.primary,
    84	                    ),
    85	              ),
    86	              const SizedBox(height: 24),
    87	              
    88	              // Dropdown para Estágio da Soja
    89	              DropdownButtonFormField<SojaStage>(
    90	                initialValue: _selectedStage,
    91	                decoration: const InputDecoration(
    92	                  labelText: 'Estágio da Soja',
    93	                  prefixIcon: Icon(Icons.grass),
    94	                  border: OutlineInputBorder(),
    95	                ),
    96	                items: SojaStage.values.map((SojaStage stage) {
    97	                  return DropdownMenuItem<SojaStage>(
    98	                    value: stage,
    99	                    child: Text(stage.label),
   100	                  );
   101	                }).toList(),
   102	                onChanged: (SojaStage? newValue) {
   103	                  setState(() {
   104	                    _selectedStage = newValue;
   105	                  });
   106	                },
   107	                validator: (value) =>
   108	                    value == null ? 'Selecione um estágio' : null,
   109	              ),
   110	              const SizedBox(height: 16),
   111	              
   112	              // Campo para Balanço de Nitrogênio (N)
   113	              TextFormField(
   114	                controller: _nBalanceController,
   115	                keyboardType: const TextInputType.numberWithOptions(decimal: true),
   116	                decoration: const InputDecoration(
   117	                  labelText: 'Balanço de Nitrogênio (N_balance)',
   118	                  prefixIcon: Icon(Icons.science),
   119	                  suffixText: 'kg/ha',
   120	                  border: OutlineInputBorder(),
   121	                ),
   122	                validator: (value) {
   123	                  if (value == null || value.isEmpty) {
   124	                    return 'Informe o balanço de N';
   125	                  }
   126	                  if (double.tryParse(value) == null) {
   127	                    return 'Insira um valor numérico válido';
   128	                  }
   129	                  return null;
   130	                },
   131	              ),
   132	              const SizedBox(height: 16),
   133	              
   134	              // Campo para pH do Solo
   135	              TextFormField(
   136	                controller: _soilPHController,
   137	                keyboardType: const TextInputType.numberWithOptions(decimal: true),
   138	                decoration: const InputDecoration(
   139	                  labelText: 'pH do Solo (soilPH)',
   140	                  prefixIcon: Icon(Icons.water_drop),
   141	                  border: OutlineInputBorder(),
   142	                ),
   143	                validator: (value) {
   144	                  if (value == null || value.isEmpty) {
   145	                    return 'Informe o pH do solo';
   146	                  }
   147	                  final ph = double.tryParse(value);
   148	                  if (ph == null) {
   149	                    return 'Insira um valor numérico válido';
   150	                  }
   151	                  if (ph < 0 || ph > 14) {
   152	                    return 'O pH deve estar entre 0 e 14';
   153	                  }
   154	                  return null;
   155	                },
   156	              ),
   157	              const SizedBox(height: 32),
   158	              
   159	              // Botão Calcular Adubo
   160	              FilledButton.icon(
   161	                onPressed: _calcularAdubo,
   162	                style: FilledButton.styleFrom(
   163	                  padding: const EdgeInsets.symmetric(vertical: 16),
   164	                  shape: RoundedRectangleBorder(
   165	                    borderRadius: BorderRadius.circular(12),
   166	                  ),
   167	                ),
   168	                icon: const Icon(Icons.calculate),
   169	                label: const Text(
   170	                  'Calcular Adubo',
   171	                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
   172	                ),
   173	              ),
   174	            ],
   175	          ),
   176	        ),
   177	      ),
   178	    );
   179	  }
   180	}
```

### B.7 referências crop_phenology_tracker
Comando:
```bash
grep -rn "crop_phenology_tracker\|CropPhenologyTracker" Analise/lib --include="*.dart" | grep -v "crop_phenology_tracker.dart"
```
Output real:
```
NÃO ENCONTRADO
```

### B.8 wc calcular_recomendacao_usecase
Comando:
```bash
wc -l "Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart"
```
Output real:
```
     123 Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart
```

### B.8 cat calcular_recomendacao_usecase
Comando:
```bash
cat -n "Analise/lib/domain/usecases/calcular_recomendacao_usecase.dart"
```
Output real:
```
     1	import 'package:soloforte/domain/formulas/calcario_formula.dart';
     2	import 'package:soloforte/domain/entities/analise_entity.dart';
     3	import 'package:soloforte/domain/entities/calibracao_entity.dart';
     4	import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';
     5	import 'package:soloforte/domain/formulas/fosforo_formula.dart';
     6	import 'package:soloforte/domain/formulas/potassio_formula.dart';
     7	import 'package:soloforte/domain/formulas/types/calcario_input.dart';
     8	import 'package:soloforte/domain/formulas/types/fosforo_input.dart';
     9	import 'package:soloforte/domain/models/analise_model.dart';
    10	import 'package:soloforte/domain/models/recomendacao_model.dart';
    11	
    12	class CalcularRecomendacaoUseCase {
    13	  /// Gera uma recomendação completa baseado em uma AnaliseModel
    14	  /// Retorna um RecomendacaoModel novo (sem ID salvo no banco ainda)
    15	  RecomendacaoModel call(
    16	      {required AnaliseModel analise, required double prntDesejado}) {
    17	    // 1 - Cálculo de Calcário (Método V%)
    18	    // Considerando por padrão V% desejado de 70% para as culturas em geral
    19	    final calcario = CalcarioFormula.metodoV(
    20	      CalcarioInput(
    21	        ctcPh7: analise.ctcTotal,
    22	        va: analise.vPct,
    23	        vd: 70.0,
    24	        prnt: prntDesejado,
    25	        profundidade: 20.0,
    26	      ),
    27	    ).ncToneladas;
    28	
    29	    // 2 - Fósforo (Considerando solo argiloso para fins do exemplo > 35%)
    30	    final pCritico = FosforoFormula.nivelCriticoMehlich1(
    31	      analise.argilaPercent == 0 ? 40.0 : analise.argilaPercent,
    32	    );
    33	    final pDose = FosforoFormula.recomendacaoCorrecao(
    34	      FosforoInput(
    35	        pAtual: analise.pMehlich ?? analise.pResina ?? 0,
    36	        nc: pCritico,
    37	        argila: analise.argilaPercent == 0 ? 25.0 : analise.argilaPercent,
    38	        referencia: 'IAC Bol.100',
    39	      ),
    40	    ).doseRecomendada;
    41	
    42	    // 3 - Potássio (Alvo de 5% de participação na CTC)
    43	    final kDose = PotassioFormula.recomendacao(
    44	      ctc: analise.ctcTotal,
    45	      kAtual: analise.k ?? 0,
    46	      participacaoDesejada: 5.0,
    47	    );
    48	
    49	    return RecomendacaoModel(
    50	      id: '', // Será gerado pelo repository
    51	      analiseId: analise.id,
    52	      cultura: analise.cultura,
    53	      necessidadeCalagem: calcario,
    54	      prnt: prntDesejado,
    55	      doseCalcario: calcario, // Simplificação
    56	      p2o5: pDose,
    57	      k2o: kDose,
    58	      citacaoCalagem: CitacaoCalibracaoModel.calagem,
    59	      citacaoGesso: CitacaoCalibracaoModel.gesso,
    60	      citacaoFosforo: CitacaoCalibracaoModel.fosforo,
    61	      citacaoPotassio: CitacaoCalibracaoModel.potassio,
    62	      citacaoEnxofre: CitacaoCalibracaoModel.enxofre,
    63	      citacaoMicronutrientes: CitacaoCalibracaoModel.micronutrientes,
    64	    );
    65	  }
    66	
    67	  RecomendacaoModel fromEntities({
    68	    required CalibracaoEntity calibracao,
    69	    required AnaliseEntity analise,
    70	  }) {
    71	    final fonteP =
    72	        calibracao.metodoPosforoSelecionado.toLowerCase().contains('mehlich')
    73	            ? FonteP.mehlich
    74	            : FonteP.resina;
    75	    final model = AnaliseModel(
    76	      id: analise.id,
    77	      userId: 'local',
    78	      produtor: analise.fazenda,
    79	      talhao: analise.talhao,
    80	      dataColeta: DateTime.now().toIso8601String(),
    81	      status: 'Gerada',
    82	      cultura: analise.cultura,
    83	      phAgua: analise.ph,
    84	      pMehlich: analise.p,
    85	      pResina: analise.p,
    86	      k: analise.k,
    87	      ca: analise.ca,
    88	      mg: analise.mg,
    89	      hMaisAl: analise.ctc - analise.sb,
    90	      b: analise.b,
    91	      cu: analise.cu,
    92	      fe: analise.fe,
    93	      mn: analise.mn,
    94	      zn: analise.zn,
    95	      argila: analise.argila * 10,
    96	      fontePrincipalP: fonteP,
    97	    );
    98	
    99	    final prntDesejado = _inferirPrnt(calibracao);
   100	    return call(
   101	      analise: model,
   102	      prntDesejado: prntDesejado,
   103	    ).copyWith(
   104	      analiseId: analise.id,
   105	      cultura: analise.cultura,
   106	    );
   107	  }
   108	
   109	  double _inferirPrnt(CalibracaoEntity calibracao) {
   110	    if (calibracao.metodoCalagemSelecionado.toLowerCase().contains('smp')) {
   111	      return 90.0;
   112	    }
   113	    if (calibracao.metodoCalagemSelecionado
   114	            .toLowerCase()
   115	            .contains('alumínio') ||
   116	        calibracao.metodoCalagemSelecionado
   117	            .toLowerCase()
   118	            .contains('aluminio')) {
   119	      return 85.0;
   120	    }
   121	    return 80.0;
   122	  }
   123	}
```

### B.8 imports calcular_recomendacao_usecase
Comando:
```bash
grep -rn "calcular_recomendacao_usecase\|CalcularRecomendacaoUseCase" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
NÃO ENCONTRADO
```

### B.9 wc absorcao_nutrientes_referencia_page
Comando:
```bash
wc -l "Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart"
```
Output real:
```
    3558 Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
```

### B.9 class/build/return absorcao_nutrientes
Comando:
```bash
grep -n "class\|Widget build\|return " "Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart" | head -30
```
Output real:
```
8:class AbsorcaoNutrientesReferenciaPage extends StatefulWidget {
16:class _AbsorcaoNutrientesReferenciaPageState
2486:      return 4.2;
2488:    return parsed;
2494:      return const _DataValue(
2502:      return _DataValue(
2513:      return const _DataValue(
2522:    return _DataValue(
2532:      return const [];
2541:    return List<_StagePoint>.generate(_stageKeys.length, (index) {
2552:      return _StagePoint(
2565:    return totalInKg < 1 ? 'g' : 'kg';
2575:  Widget build(BuildContext context) {
2586:    return Scaffold(
2622:    return Container(
2661:    return Container(
2693:    return InkWell(
2722:    return _buildCard(
2870:    return _buildCard(
2945:    return _buildCard(
2964:            return Padding(
3038:    return _buildCard(
3095:    return _buildCard(
3144:    return _buildCard(
3258:    return Column(
3275:    return nutrients.map((nutrient) {
3279:      return _ReferenceTableRow(label: label, value: formatted);
3286:      return const [];
3289:    return List<_ReferenceTableRow>.generate(_stageKeys.length, (index) {
3294:      return _ReferenceTableRow(
```

### B.9 imports absorcao_nutrientes
Comando:
```bash
grep -rn "absorcao_nutrientes_referencia_page\|AbsorcaoNutrientesReferenciaPage" Analise/lib --include="*.dart" | grep "import"
```
Output real:
```
Analise/lib/core/router/app_router.dart:27:import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart';
```

### C.1 mapa completo 391
Comando:
```bash
grep -rn "391\|k_mgdm3\|/ 391\|/391" Analise/lib --include="*.dart"
```
Output real:
```
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:153:          dynamic kRaw = item['k_mgdm3'] ?? item['k'];
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:157:              (item.containsKey('k_mgdm3') || (kVal > 10))) {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:159:            kVal = kVal / 391.0;
Analise/lib/features/analise/domain/validation/analise_data_contract.dart:796:      normalizedValue = parsed / 391.0;
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:87:  _UnitStep('cmolc/dm³', 1.0 / 391, decimals: 3),
Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:642:      case 'k_mgdm3':
Analise/lib/data/lab_templates/sellar_import_service.dart:79:    // - JSON novo: k_mgdm3 (mg/dm³) -> converte para cmolc/dm³
Analise/lib/data/lab_templates/sellar_import_service.dart:82:    final kRawMgDm3 = toDouble(value('k_mgdm3'));
Analise/lib/data/lab_templates/mb_import_service.dart:49:    // K: mg/dm³ → cmolc/dm³ (÷ 391)
Analise/lib/data/lab_templates/mb_import_service.dart:50:    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;
Analise/lib/data/lab_templates/sellar_template.dart:3:// K vem em mg/dm³ no JSON (campo k_mgdm3); ImportService converte ÷ 391
Analise/lib/data/lab_templates/sellar_template.dart:4:// Ref: Conversoes.kMgDm3Factor = 391
Analise/lib/data/lab_templates/sellar_template.dart:33:  'k_mgdm3': 'k', // ImportService converte ÷ 391
Analise/lib/data/lab_templates/lab_pdf_parser.dart:103:              'k_mgdm3': _toDouble(parsed.values[7]),
Analise/lib/data/lab_templates/lab_pdf_parser.dart:467:      'k_mgdm3': _toDouble(macroValues[4]),
Analise/lib/data/lab_templates/lab_pdf_parser.dart:586:        'k_mgdm3': kValues.length > i ? _toDouble(kValues[i]) : null,
Analise/lib/data/lab_templates/exata_brasil_import_service.dart:50:    final kCmolc = (toDouble(raw('k_mgdm3')) ?? 0.0) / 391.0;
Analise/lib/data/lab_templates/mb_template.dart:11:    'k': 'mg/dm³ (÷ 391)',
Analise/lib/data/lab_templates/mb_template.dart:20:/// - K em mg/dm³ (k_mgdm3) → ImportService converte ÷ 391
Analise/lib/data/lab_templates/mb_template.dart:39:  // K — mg/dm³; ImportService converte ÷ 391
Analise/lib/data/lab_templates/mb_template.dart:40:  'K': 'k_mgdm3',
Analise/lib/data/lab_templates/exata_brasil_template.dart:21:/// - K vem em mg/dm³ (k_mgdm3) → converter ÷ 391 para cmolc/dm³
Analise/lib/data/lab_templates/exata_brasil_template.dart:48:  // K vem em mg/dm³ no JSON (campo k_mgdm3); ImportService converte ÷ 391
Analise/lib/data/lab_templates/exata_brasil_template.dart:49:  'K (NH4Cl)': 'k_mgdm3',
Analise/lib/domain/usecases/recomendacao_engine.dart:244:            kAtualMgDm3: analise.k * 391.0,
Analise/lib/domain/formulas/conversoes.dart:19:  /// K (mg/dm³) → cmolc/dm³: dividir por 391
Analise/lib/domain/formulas/conversoes.dart:20:  static const double kMgDm3Factor = 391.0;
Analise/lib/domain/formulas/calagem_engine.dart:482:    final kKgHa = deficitK * 391.0;
Analise/lib/domain/formulas/potassio_formula.dart:2:  static const double _fatorCmolcParaK2O = 391.0 * 1.205 * 2.0; // 942.21
Analise/lib/domain/formulas/potassio_formula.dart:20:  static double kMgDm3ToCmolc(double kMgDm3) => kMgDm3 / 391.0;
Analise/lib/domain/formulas/potassio_formula.dart:68:    final deficitCmolc = deficitMgDm3 / 391.0;
```

### C.2 contexto analise_data_contract 785-810
Comando:
```bash
sed -n '785,810p' Analise/lib/features/analise/domain/validation/analise_data_contract.dart
```
Output real:
```
        ],
      );
    }

    var normalizedValue = parsed;
    final warnings = <ValidationIssue>[];

    // Conversões contextuais por laboratório.
    if (key == 'k' &&
        (labId == 'exata_brasil' || labId == 'mb') &&
        parsed > 12) {
      normalizedValue = parsed / 391.0;
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_CONVERT_K_MGDM3',
          message: 'K convertido automaticamente de mg/dm³ para cmolc/dm³.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    if ((key == 'k' ||
```

### C.3 contexto analise_resultado_table 78-100
Comando:
```bash
sed -n '78,100p' Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart
```
Output real:
```
}

const _cmolcSteps = [
  _UnitStep('cmolc/dm³', 1.0, decimals: 2),
  _UnitStep('mmolc/dm³', 10.0, decimals: 1),
];

const _kmgSteps = [
  _UnitStep('mg/dm³', 1.0, decimals: 2),
  _UnitStep('cmolc/dm³', 1.0 / 391, decimals: 3),
];

List<_UnitStep> _stepsFor(ConvType type) {
  switch (type) {
    case ConvType.cmolc:
      return _cmolcSteps;
    case ConvType.kmg:
      return _kmgSteps;
    case ConvType.none:
      return const [];
  }
}

```

### D.1 analise_provider 80-105
Comando:
```bash
sed -n '80,105p' Analise/lib/features/analise/presentation/providers/analise_provider.dart
```
Output real:
```
    ref
        .read(analiseRepositoryProvider)
        .recoverPendingBatches(timeout: const Duration(minutes: 10))
        .catchError((_) {});

    if (!isDemoOn) {
      yield* ref.read(getAnalisesUsecaseProvider).stream();
      return;
    }

    // Demo mode ativo: carregar seeds locais uma única vez
    final localDs = AnaliseLocalDatasource(useAssetSeed: true);
    final seeds = await localDs.getAnalises();
    final seedsMapped = seeds
        .map((m) => m.copyWith(id: 'demo_${m.id}') as AnaliseSolo)
        .toList(growable: false);

    // Mesclar seeds ANTES de cada emissão do Firestore
    yield* ref
        .read(getAnalisesUsecaseProvider)
        .stream()
        .map((firestoreList) => [...seedsMapped, ...firestoreList]);
  }

  Future<void> salvar(AnaliseSolo analise) async {
    if (AppConfig.useFirestore && FirebaseAuth.instance.currentUser == null) {
```

### D.1 flags no analise_provider
Comando:
```bash
grep -n "useFirestore\|isRelease\|kDebugMode\|demoMode\|useAssetSeed\|AppConfig" Analise/lib/features/analise/presentation/providers/analise_provider.dart
```
Output real:
```
29:  if (AppConfig.allowAnaliseMockMode) {
75:    final isDemoAsync = ref.watch(demoModeNotifierProvider);
77:            await ref.watch(demoModeNotifierProvider.future)) ==
91:    final localDs = AnaliseLocalDatasource(useAssetSeed: true);
105:    if (AppConfig.useFirestore && FirebaseAuth.instance.currentUser == null) {
112:    if (AppConfig.useFirestore && FirebaseAuth.instance.currentUser == null) {
```

### D.1 flags no AppConfig
Comando:
```bash
grep -n "useFirestore\|allowAnaliseMockMode\|release\|dart-define\|bool.fromEnvironment" Analise/lib/core/config/app_config.dart
```
Output real:
```
5:/// [useFirestore] controla qual datasource está ativo:
8:///     `--dart-define=ANALISE_MOCK_MODE=true`
18:  static const bool useAnaliseMockMode = bool.fromEnvironment(
23:  /// Mock só pode rodar fora de release.
25:  static bool get allowAnaliseMockMode => !kReleaseMode && useAnaliseMockMode;
28:  /// `false` -> Mock local ativo (somente diagnóstico explícito fora de release)
29:  static bool get useFirestore => !allowAnaliseMockMode;
50:  static const bool enableAnaliseTelemetryInDebug = bool.fromEnvironment(
```

### D.2 referências AnaliseLocalDatasource
Comando:
```bash
grep -rn "AnaliseLocalDatasource\|analise_local_datasource" Analise/lib --include="*.dart" | grep -v "_test.dart"
```
Output real:
```
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:67:class AnaliseLocalDatasource implements AnaliseDataSource {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:80:  AnaliseLocalDatasource({
Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:15:    AutoDisposeProvider<AnaliseLocalDatasource>.internal(
Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:27:typedef AnaliseLocalDatasourceRef
Analise/lib/features/analise/presentation/providers/analise_provider.g.dart:28:    = AutoDisposeProviderRef<AnaliseLocalDatasource>;
Analise/lib/features/analise/presentation/providers/analise_provider.dart:13:import 'package:soloforte/features/analise/data/datasources/analise_local_datasource.dart';
Analise/lib/features/analise/presentation/providers/analise_provider.dart:19:AnaliseLocalDatasource analiseLocalDatasource(AnaliseLocalDatasourceRef ref) {
Analise/lib/features/analise/presentation/providers/analise_provider.dart:20:  return AnaliseLocalDatasource();
Analise/lib/features/analise/presentation/providers/analise_provider.dart:91:    final localDs = AnaliseLocalDatasource(useAssetSeed: true);
```

### D.3 interface analise_datasource
Comando:
```bash
cat -n "Analise/lib/features/analise/data/datasources/analise_datasource.dart"
```
Output real:
```
     1	import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
     2	import 'package:soloforte/features/analise/data/models/produtor_model.dart';
     3	import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
     4	
     5	abstract class AnaliseDataSource {
     6	  Future<List<AnaliseSoloModel>> getAnalises();
     7	  Stream<List<AnaliseSoloModel>> watchAnalises();
     8	  Future<void> saveAnalise(AnaliseSoloModel analise);
     9	  Future<SaveBatchResult> saveAnalisesBatch(List<AnaliseSoloModel> analises);
    10	  Future<void> recoverPendingBatches({Duration timeout});
    11	  Future<void> deleteAnalise(String id);
    12	  Future<List<ProdutorModel>> getProdutores();
    13	}
```

### D.3 repository impl grep datasource
Comando:
```bash
grep -n "AnaliseLocalDatasource\|AnaliseFirestoreDatasource\|datasource" "Analise/lib/features/analise/data/repositories/analise_repository_impl.dart" | head -15
```
Output real:
```
5:import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
```

### E.1 router 225-250
Comando:
```bash
sed -n '225,250p' Analise/lib/core/router/app_router.dart
```
Output real:
```
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => const CalibracaoPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recomendacao',
                    builder: (context, state) {
                      final extra = state.extra;
                      final analiseId = extra is String ? extra : null;
                      return RecomendacaoScreen(analiseId: analiseId);
                    },
                  ),
                  GoRoute(
                    path: 'referencias',
                    builder: (context, state) => const LabReferenciasPage(),
                    routes: [
                      GoRoute(
                        path: 'tecnicas',
                        builder: (context, state) => const BaseDadosPage(),
                      ),
                      GoRoute(
                        path: 'detalhes',
                        builder: (context, state) {
```

### E.2 grep rotas
Comando:
```bash
grep -n "GoRoute\|path:\|name:\|builder:\|redirect:" "Analise/lib/core/router/app_router.dart"
```
Output real:
```
70:class GoRouterAuthRefreshNotifier extends ChangeNotifier {
71:  GoRouterAuthRefreshNotifier(Stream<User?> stream) {
92:final routerProvider = Provider<GoRouter>((ref) {
94:  final authRefresh = GoRouterAuthRefreshNotifier(auth.authStateChanges());
97:  return GoRouter(
101:    redirect: (context, state) {
116:        path: path,
121:      GoRoute(
122:        path: AppRoutes.authBootstrap,
123:        builder: (context, state) => const _AuthBootstrapPage(),
125:      GoRoute(
126:        path: AppRoutes.login,
127:        builder: (context, state) => const LoginPage(),
129:      GoRoute(
130:        path: AppRoutes.cadastro,
131:        builder: (context, state) => const CadastroPage(),
133:      GoRoute(
134:        path: AppRoutes.recuperarSenha,
135:        builder: (context, state) => const RecuperarSenhaPage(),
137:      GoRoute(
138:        path: AppRoutes.culturas,
139:        builder: (context, state) => const CulturasScreen(),
141:      GoRoute(
142:        path: AppRoutes.historico,
143:        redirect: (_, __) => AppRoutes.labHistorico,
145:      GoRoute(
146:        path: AppRoutes.baseDadosLegacyAlias,
147:        redirect: (_, __) => AppRoutes.labRefTecnicas,
149:      GoRoute(
150:        path: AppRoutes.baseDados,
151:        redirect: (_, __) => AppRoutes.labRefTecnicas,
153:      GoRoute(
154:        path: AppRoutes.baseDadosForm,
155:        redirect: (_, __) => AppRoutes.labRefNova,
157:      GoRoute(
158:        path: AppRoutes.baseDadosDetalhe,
159:        redirect: (_, __) => AppRoutes.labRefTecnicas,
161:      GoRoute(
162:        path: AppRoutes.tabelaMetricas,
163:        redirect: (_, __) => AppRoutes.labRefMetricas,
166:        builder: (context, state, navigationShell) =>
171:              GoRoute(
172:                path: AppRoutes.analise,
173:                builder: (context, state) => const AnalisePage(),
175:                  GoRoute(
176:                    path: 'nova',
177:                    builder: (context, state) => const AnaliseFormPage(),
179:                  GoRoute(
180:                    path: 'detalhe/:id',
181:                    builder: (context, state) {
186:                      GoRoute(
187:                        path: 'editar',
188:                        builder: (context, state) {
203:                              GoRouter.of(context).go(AppRoutes.analise);
218:              GoRoute(
219:                path: AppRoutes.lab,
220:                builder: (context, state) => const LabPage(),
222:                  GoRoute(
223:                    path: 'calibracao',
224:                    builder: (context, state) => const CalibracaoSeletorPage(),
226:                      GoRoute(
227:                        path: 'editar',
228:                        builder: (context, state) => const CalibracaoPage(),
232:                  GoRoute(
233:                    path: 'recomendacao',
234:                    builder: (context, state) {
240:                  GoRoute(
241:                    path: 'referencias',
242:                    builder: (context, state) => const LabReferenciasPage(),
244:                      GoRoute(
245:                        path: 'tecnicas',
246:                        builder: (context, state) => const BaseDadosPage(),
248:                      GoRoute(
249:                        path: 'detalhes',
250:                        builder: (context, state) {
260:                      GoRoute(
261:                        path: 'nova',
262:                        builder: (context, state) => const BaseDadosFormPage(),
264:                      GoRoute(
265:                        path: 'metricas',
266:                        builder: (context, state) => const TabelaMetricasPage(),
268:                      GoRoute(
269:                        path: 'absorcao-nutrientes',
270:                        builder: (context, state) =>
275:                  GoRoute(
276:                    path: 'historico',
277:                    builder: (context, state) => const HistoricoPage(),
285:              GoRoute(
286:                path: AppRoutes.mapa,
287:                builder: (context, state) => MapaPage(
295:              GoRoute(
296:                path: AppRoutes.config,
297:                builder: (context, state) => const ConfigPage(),
299:                  GoRoute(
300:                    path: 'feedback',
301:                    builder: (context, state) => const FeedbackPage(),
```

### E.2 bloco completo de rotas 118-306
Comando:
```bash
sed -n '118,306p' Analise/lib/core/router/app_router.dart
```
Output real:
```
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.authBootstrap,
        builder: (context, state) => const _AuthBootstrapPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: AppRoutes.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),
      GoRoute(
        path: AppRoutes.culturas,
        builder: (context, state) => const CulturasScreen(),
      ),
      GoRoute(
        path: AppRoutes.historico,
        redirect: (_, __) => AppRoutes.labHistorico,
      ),
      GoRoute(
        path: AppRoutes.baseDadosLegacyAlias,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDados,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDadosForm,
        redirect: (_, __) => AppRoutes.labRefNova,
      ),
      GoRoute(
        path: AppRoutes.baseDadosDetalhe,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.tabelaMetricas,
        redirect: (_, __) => AppRoutes.labRefMetricas,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analise,
                builder: (context, state) => const AnalisePage(),
                routes: [
                  GoRoute(
                    path: 'nova',
                    builder: (context, state) => const AnaliseFormPage(),
                  ),
                  GoRoute(
                    path: 'detalhe/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AnaliseDetailScreen(analiseId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          final container = ProviderScope.containerOf(context);
                          final lista = container
                                  .read(analiseNotifierProvider)
                                  .valueOrNull ??
                              [];
                          final feature_analise.AnaliseSolo? analise = lista
                              .cast<feature_analise.AnaliseSolo?>()
                              .firstWhere(
                                (a) => a?.id == id,
                                orElse: () => null,
                              );
                          if (analise == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              GoRouter.of(context).go(AppRoutes.analise);
                            });
                            return const SizedBox.shrink();
                          }
                          return NovaAnaliseScreen(analiseParaEditar: analise);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.lab,
                builder: (context, state) => const LabPage(),
                routes: [
                  GoRoute(
                    path: 'calibracao',
                    builder: (context, state) => const CalibracaoSeletorPage(),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => const CalibracaoPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recomendacao',
                    builder: (context, state) {
                      final extra = state.extra;
                      final analiseId = extra is String ? extra : null;
                      return RecomendacaoScreen(analiseId: analiseId);
                    },
                  ),
                  GoRoute(
                    path: 'referencias',
                    builder: (context, state) => const LabReferenciasPage(),
                    routes: [
                      GoRoute(
                        path: 'tecnicas',
                        builder: (context, state) => const BaseDadosPage(),
                      ),
                      GoRoute(
                        path: 'detalhes',
                        builder: (context, state) {
                          final ref = state.extra is ReferenciaTecnica
                              ? state.extra as ReferenciaTecnica
                              : null;
                          if (ref == null) {
                            return const BaseDadosPage();
                          }
                          return BaseDadosDetailPage(referencia: ref);
                        },
                      ),
                      GoRoute(
                        path: 'nova',
                        builder: (context, state) => const BaseDadosFormPage(),
                      ),
                      GoRoute(
                        path: 'metricas',
                        builder: (context, state) => const TabelaMetricasPage(),
                      ),
                      GoRoute(
                        path: 'absorcao-nutrientes',
                        builder: (context, state) =>
                            const AbsorcaoNutrientesReferenciaPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'historico',
                    builder: (context, state) => const HistoricoPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mapa,
                builder: (context, state) => MapaPage(
                  initialAnaliseId: state.uri.queryParameters['analiseId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.config,
                builder: (context, state) => const ConfigPage(),
                routes: [
                  GoRoute(
                    path: 'feedback',
                    builder: (context, state) => const FeedbackPage(),
                  ),
                ],
              ),
            ],
          ),
```

### E.3 push/go/replace
Comando:
```bash
grep -rn "context\.push\|context\.go\|context\.replace\|context\.pushReplacement" Analise/lib --include="*.dart" | grep -v "_test.dart" | sort
```
Output real:
```
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:133:                    context.push(
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:155:                    context.go(
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:174:                  context.go(
Analise/lib/features/analise/presentation/screens/analise_detail_screen.dart:49:              context.push(
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:220:                        onTap: () => context.push(AppRoutes.analiseForm),
Analise/lib/features/auth/presentation/login/login_page.dart:518:              onTap: () => context.push(AppRoutes.cadastro),
Analise/lib/features/auth/presentation/login/login_page.dart:54:          context.go(AppRoutes.home);
Analise/lib/features/auth/presentation/login/login_page.dart:650:                  onPressed: () => context.push(AppRoutes.recuperarSenha),
Analise/lib/features/auth/presentation/login/login_page.dart:685:                    onTap: () => context.push(AppRoutes.cadastro),
Analise/lib/features/config/presentation/base_dados/base_dados_page.dart:27:        onPressed: () => context.push(AppRoutes.labRefNova),
Analise/lib/features/config/presentation/base_dados/base_dados_page.dart:41:                    onTap: () => context.push(
Analise/lib/features/config/presentation/config_page.dart:310:                      onTap: () => context.push(AppRoutes.feedback),
Analise/lib/features/config/presentation/config_page.dart:412:                              context.go(AppRoutes.login);
Analise/lib/features/historico/presentation/historico_page.dart:138:            onPressed: () => context.push(AppRoutes.lab),
Analise/lib/features/historico/presentation/historico_page.dart:28:            onPressed: () => context.push(AppRoutes.lab),
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart:85:    context.push(AppRoutes.labCalibracaoEditar);
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart:90:    context.push(AppRoutes.labCalibracaoEditar);
Analise/lib/features/laboratorio/presentation/lab_page.dart:26:            onTap: () => context.push(AppRoutes.labCalibracao),
Analise/lib/features/laboratorio/presentation/lab_page.dart:38:            onTap: () => context.push(AppRoutes.labRecomendacao),
Analise/lib/features/laboratorio/presentation/lab_page.dart:50:            onTap: () => context.push(AppRoutes.labReferencias),
Analise/lib/features/laboratorio/presentation/lab_page.dart:66:            onTap: () => context.push(AppRoutes.labHistorico),
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart:173:              onTap: () => context.push(AppRoutes.config),
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:636:      context.go(AppRoutes.labHistorico);
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:79:            context.go(AppRoutes.lab);
Analise/lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart:24:            onTap: () => context.push(AppRoutes.labRefTecnicas),
Analise/lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart:36:            onTap: () => context.push(AppRoutes.labRefMetricas),
Analise/lib/features/laboratorio/presentation/referencias/lab_referencias_page.dart:48:            onTap: () => context.push(AppRoutes.labRefAbsorcaoNutrientes),
Analise/lib/features/mapa/presentation/widgets/modulos_bottom_sheet.dart:89:                          context.go(item.route);
```

### F.1 force unwrap
Comando:
```bash
grep -rn "!\." Analise/lib --include="*.dart" | grep -v "_test.dart" | grep -v ".freezed.dart" | grep -v ".g.dart" | head -30
```
Output real:
```
Analise/lib/core/widgets/app_dropdown.dart:28:    final hasError = errorText != null && errorText!.isNotEmpty;
Analise/lib/core/widgets/app_input.dart:120:    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:320:      _batchByKey[idempotencyKey] = _batchByKey[idempotencyKey]!.copyWith(
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:358:      _batchByKey[idempotencyKey] = _batchByKey[idempotencyKey]!.copyWith(
Analise/lib/features/analise/domain/models/analise_draft.dart:147:      id: (persistedId != null && persistedId!.isNotEmpty)
Analise/lib/features/analise/presentation/widgets/localizacao_captura_widget.dart:86:                    ? ' · precisão ${r.accuracy!.toStringAsFixed(0)} m'
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:579:      return widget.value!.toStringAsFixed(widget.baseDecimals);
Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:59:        title = field!.label,
Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:65:        title = calcField!.label,
Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:516:        key: ValueKey('${row.calcField!.key}_calc_$index'),
Analise/lib/features/analise/presentation/widgets/analise_table_widget.dart:520:            ? derivados[index][row.calcField!.key]
Analise/lib/features/analise/presentation/widgets/analise_label_cell.dart:45:          if (unit != null && unit!.isNotEmpty) ...[
Analise/lib/features/analise/presentation/widgets/analise_calc_cell.dart:22:    final text = value != null ? value!.toStringAsFixed(decimals) : '—';
Analise/lib/features/mapa/presentation/mapa_page.dart:407:    final text = (value?.trim().isNotEmpty ?? false) ? value!.trim() : '-';
Analise/lib/features/config/presentation/config_page.dart:564:    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart:102:                                if (formKey.currentState!.validate()) {
Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart:126:                          if (formKey.currentState!.validate()) {
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:62:      if (formKey.currentState!.validate()) {
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:164:                                v!.isEmpty ? AppStrings.campoObrigatorio : null,
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:226:                                v!.isEmpty ? AppStrings.campoObrigatorio : null,
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:262:                              if (v!.isEmpty) {
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:279:                                v!.length < 6 ? AppStrings.senhaMinimo6 : null,
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:289:                              if (formKey3.currentState!.validate()) {
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:300:                              if (v!.isEmpty) {
Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart:314:                              if (formKey3.currentState!.validate()) {
Analise/lib/features/auth/presentation/login/login_page.dart:34:      if (formKey.currentState!.validate()) {
Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart:48:    if (_formKey.currentState!.validate()) {
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:550:        'caAlvo': alvos['ca']!.toDouble(),
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:551:        'mgAlvo': alvos['mg']!.toDouble(),
Analise/lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart:552:        'kAlvo': alvos['k']!.toDouble(),
```

### F.2 catch(e)
Comando:
```bash
grep -rn "catch (e)" Analise/lib --include="*.dart" | grep -v "_test.dart" | grep -v ".freezed.dart" | grep -v ".g.dart" | head -20
```
Output real:
```
Analise/lib/core/services/location_service.dart:31:    } catch (e) {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:188:    } catch (e) {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:336:    } catch (e) {
Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart:14:    } catch (e) {
Analise/lib/features/analise/presentation/providers/location_provider.dart:45:    } on LocationException catch (e) {
Analise/lib/features/analise/presentation/screens/nova_analise_screen.dart:519:    } on LabConfiancaBaixaException catch (e) {
Analise/lib/features/analise/presentation/screens/nova_analise_screen.dart:576:    } catch (e) {
Analise/lib/features/analise/presentation/controllers/nova_analise_controller.dart:203:    } on LocationException catch (e) {
Analise/lib/features/config/presentation/tabela_metricas_page.dart:268:    } catch (e) {
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:637:    } catch (e) {
Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart:657:    } catch (e) {
Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart:20:    } catch (e) {
Analise/lib/data/datasources/remote/recomendacao_firestore_datasource.dart:37:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:33:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:42:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:51:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:67:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:187:    } on FirebaseException catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:195:    } catch (e) {
Analise/lib/data/datasources/remote/analise_firestore_datasource.dart:372:    } catch (e) {
```

### F.2 contextos de catch
Comando:
```bash
(sed -n '26,34p' Analise/lib/core/services/location_service.dart; sed -n '1,24p' Analise/lib/features/analise/data/datasources/pdf_parser_datasource.dart; sed -n '258,278p' Analise/lib/features/config/presentation/tabela_metricas_page.dart; sed -n '628,665p' Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart)
```
Output real:
```
---core/services/location_service.dart 26-34---
      
      return (
        latitude: double.parse(position.latitude.toStringAsFixed(8)),
        longitude: double.parse(position.longitude.toStringAsFixed(8)),
      );
    } catch (e) {
      return null;
    }
  }
---features/analise/data/datasources/pdf_parser_datasource.dart 1-24---
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soloforte/features/analise/data/models/lab_template_model.dart';

class PdfParserDatasource {
  Future<List<LabTemplateModel>> loadLabTemplates() async {
    try {
      // Exemplo lendo da pasta assets. Em dev não teremos o pdf gerado, mas deixamos pronto
      final String jsonString = await rootBundle.loadString('assets/lab_templates/soloagro.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      
      final template = LabTemplateModel.fromJson(jsonMap);
      return [template];
    } catch (e) {
      // Silenciar erro se o arquivo não existir ainda durante o mock
      return [];
    }
  }
}
---features/config/presentation/tabela_metricas_page.dart 258-278---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tabela salva com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

---features/laboratorio/presentation/recomendacao/recomendacao_screen.dart 628-665---
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Recomendação salva no Histórico!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.labHistorico);
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _exportarPdf(ResultadoRecomendacao resultado) async {
    setState(() => _exportando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await AppObservability.instance.trace(
        'recomendacao_export_pdf',
        () async {
          final laudo = _toLaudo(resultado, uid);
          await LaudoPdfGenerator.gerarECompartilhar(laudo);
        },
        attributes: {'flow': 'recomendacao', 'action': 'exportar_pdf'},
      );
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro ao gerar PDF: $e');
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  LaudoRecomendacao _toLaudo(ResultadoRecomendacao resultado, String uid) {
```

### F.3 async/unawaited
Comando:
```bash
grep -rn "unawaited\|// ignore.*await\|async.*{" Analise/lib --include="*.dart" | grep -v "_test.dart" | head -15
```
Output real:
```
Analise/lib/core/services/location_service.dart:4:  Future<({double latitude, double longitude})?> getCurrentLocation() async {
Analise/lib/core/services/app_observability.dart:35:  Future<void> initialize() async {
Analise/lib/core/services/app_observability.dart:62:      unawaited(
Analise/lib/core/services/app_observability.dart:72:      unawaited(
Analise/lib/core/services/app_observability.dart:88:  }) async {
Analise/lib/core/services/app_observability.dart:108:  }) async {
Analise/lib/core/services/app_observability.dart:130:  }) async {
Analise/lib/features/analise/application/observability/analise_telemetry.dart:59:    unawaited(_post(event));
Analise/lib/features/analise/application/observability/analise_telemetry.dart:62:  Future<void> _post(Map<String, Object?> event) async {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:100:  Future<void> _loadMockData() async {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:194:  Future<List<AnaliseSoloModel>> getAnalises() async {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:205:  Future<void> saveAnalise(AnaliseSoloModel analise) async {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:210:  Stream<List<AnaliseSoloModel>> watchAnalises() async* {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:215:  Future<void> _notify() async {
Analise/lib/features/analise/data/datasources/analise_local_datasource.dart:221:      List<AnaliseSoloModel> analises) async {
```

### F.4 context após await (comando solicitado)
Comando:
```bash
grep -rn "context\." Analise/lib --include="*.dart" | grep -v "_test.dart" | grep -v ".freezed.dart" | grep -B2 "await" | grep "context\." | head -20
```
Output real:
```
NÃO ENCONTRADO
```

### F.5 controllers
Comando:
```bash
grep -rn "TextEditingController\|AnimationController\|ScrollController" Analise/lib --include="*.dart" | grep -v "_test.dart" | grep -v ".freezed.dart" | head -20
```
Output real:
```
Analise/lib/core/widgets/app_button.dart:28:  late AnimationController _controller;
Analise/lib/core/widgets/app_button.dart:34:    _controller = AnimationController(
Analise/lib/core/widgets/app_input.dart:37:  final TextEditingController? controller;
Analise/lib/core/widgets/app_input.dart:67:  TextEditingController? _internalController;
Analise/lib/core/widgets/app_input.dart:76:          TextEditingController(text: widget.initialValue ?? '');
Analise/lib/core/widgets/app_input.dart:94:            TextEditingController(text: widget.initialValue ?? '');
Analise/lib/core/widgets/app_input.dart:263:  final TextEditingController? controller;
Analise/lib/core/widgets/app_input.dart:306:  final TextEditingController? controller;
Analise/lib/core/widgets/nutriente_card.dart:51:  late AnimationController _controller;
Analise/lib/core/widgets/nutriente_card.dart:61:    _controller = AnimationController(
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:21:  final TextEditingController _searchController = TextEditingController();
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:22:  final ScrollController _scrollController = ScrollController();
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:548:  late AnimationController _ac;
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:555:    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart:39:  late TextEditingController _ctrl;
Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart:45:    _ctrl = TextEditingController(text: widget.initialValue ?? '');
Analise/lib/features/analise/presentation/widgets/analise_section_row.dart:11:  final ScrollController scrollController;
Analise/lib/features/analise/presentation/widgets/num_field_widget.dart:6:  final TextEditingController controller;
Analise/lib/features/config/presentation/tabela_metricas_page.dart:304:  late TextEditingController _ctrl;
Analise/lib/features/config/presentation/tabela_metricas_page.dart:309:    _ctrl = TextEditingController(
```

### F.5 dispose
Comando:
```bash
grep -rn "dispose()" Analise/lib --include="*.dart" | grep -v "_test.dart" | head -20
```
Output real:
```
Analise/lib/core/widgets/app_button.dart:44:  void dispose() {
Analise/lib/core/widgets/app_button.dart:45:    _controller.dispose();
Analise/lib/core/widgets/app_button.dart:46:    super.dispose();
Analise/lib/core/widgets/app_input.dart:89:        _internalController?.dispose();
Analise/lib/core/widgets/app_input.dart:112:  void dispose() {
Analise/lib/core/widgets/app_input.dart:113:    _internalController?.dispose();
Analise/lib/core/widgets/app_input.dart:114:    if (widget.focusNode == null) _focusNode.dispose();
Analise/lib/core/widgets/app_input.dart:115:    super.dispose();
Analise/lib/core/widgets/nutriente_card.dart:84:  void dispose() {
Analise/lib/core/widgets/nutriente_card.dart:85:    _controller.dispose();
Analise/lib/core/widgets/nutriente_card.dart:86:    super.dispose();
Analise/lib/core/router/app_router.dart:86:  void dispose() {
Analise/lib/core/router/app_router.dart:88:    super.dispose();
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:29:  void dispose() {
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:30:    _searchController.dispose();
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:31:    _scrollController.dispose();
Analise/lib/features/analise/presentation/screens/analise_list_screen.dart:32:    super.dispose();
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:569:  void dispose() {
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:570:    _ac.dispose();
Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart:571:    super.dispose();
```

### F.5 arquivos com controller
Comando:
```bash
grep -rn "TextEditingController\|AnimationController\|ScrollController" Analise/lib --include="*.dart" | grep -v "_test.dart" | grep -v ".freezed.dart" | cut -d: -f1 | sort -u
```
Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_button.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/app_input.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/core/widgets/nutriente_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/screens/analise_list_screen.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_input_cell.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_resultado_table.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_section_row.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/num_field_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/login/login_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/config/presentation/tabela_metricas_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/crop/presentation/widgets/crop_phenology_tracker.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
```

### F.5 arquivos com controller sem dispose() no mesmo arquivo
Comando:
```bash
(varredura auxiliar por arquivo)
```
Output real:
```
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/analise_section_row.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/analise/presentation/widgets/num_field_widget.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/cadastro/cadastro_page.dart
/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart
```

### G.1 codemagic completo
Comando:
```bash
cat ../codemagic.yaml 2>/dev/null || cat codemagic.yaml 2>/dev/null
```
Output real:
```
workflows:
  ios-testflight:
    name: SoloForte iOS TestFlight Build
    instance_type: mac_mini_m1
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      groups:
        - app_store_credentials # Environment variables via Codemagic dashboard
    scripts:
      - name: Instalar dependências
        script: cd Analise && flutter pub get
      - name: Gerar arquivos de código (Freezed/Riverpod)
        script: cd Analise && dart run build_runner build --delete-conflicting-outputs
      - name: Verificar integridade do código
        script: cd Analise && flutter analyze
      - name: Rodar suíte de testes
        script: cd Analise && flutter test
      - name: Build iOS Release
        script: |
          cd Analise

          # Garante build number/name conforme `pubspec.yaml`.
          PUBSPEC_VERSION_LINE="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n 1)"
          if [ -z "${PUBSPEC_VERSION_LINE}" ]; then
            echo "Nao foi possivel ler 'version:' do pubspec.yaml"
            exit 1
          fi
          BUILD_NAME="${PUBSPEC_VERSION_LINE%%+*}"
          BUILD_NUMBER="${PUBSPEC_VERSION_LINE##*+}"
          echo "pubspec version=${PUBSPEC_VERSION_LINE} (build_name=${BUILD_NAME}, build_number=${BUILD_NUMBER})"

          flutter clean
          flutter build ios --release --no-codesign --build-name="${BUILD_NAME}" --build-number="${BUILD_NUMBER}"

          xcodebuild archive -workspace ios/Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/ios/Runner.xcarchive \
            -allowProvisioningUpdates \
            -IDECustomDerivedDataLocation=build/ios/DerivedData \
            COMPILER_INDEX_STORE_ENABLE=NO \
            CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
            MARKETING_VERSION="${BUILD_NAME}" \
            FLUTTER_BUILD_NAME="${BUILD_NAME}" \
            FLUTTER_BUILD_NUMBER="${BUILD_NUMBER}"

          ACTUAL_BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' build/ios/Runner.xcarchive/Products/Applications/Runner.app/Info.plist)"
          ACTUAL_BUILD_NAME="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' build/ios/Runner.xcarchive/Products/Applications/Runner.app/Info.plist)"
          echo "Built CFBundleVersion in archive: ${ACTUAL_BUILD_NUMBER}"
          echo "Built CFBundleShortVersionString in archive: ${ACTUAL_BUILD_NAME}"
          if [ "${ACTUAL_BUILD_NUMBER}" != "${BUILD_NUMBER}" ]; then
            echo "ERRO: CFBundleVersion final (${ACTUAL_BUILD_NUMBER}) difere do esperado (${BUILD_NUMBER})."
            exit 1
          fi
    artifacts:
      - Analise/build/ios/ipa/*.ipa
      - Analise/coverage/lcov.info
      - Analise/test/failures/**
      - /tmp/xcodebuild_logs/*.log
      - Analise/flutter_drive.log
    publishing:
      app_store_connect:
        auth:
          integration: apple_developer_portal
        submit_to_testflight: true
```

### H.1 grep demo/reviewer
Comando:
```bash
grep -rn "demo\|Demo\|test@\|reviewer\|apple.*review" Analise/lib --include="*.dart" | grep -v "_test.dart" | head -15
```
Output real:
```
Analise/lib/features/analise/presentation/providers/analise_provider.dart:14:import 'package:soloforte/features/config/application/providers/demo_mode_provider.dart';
Analise/lib/features/analise/presentation/providers/analise_provider.dart:75:    final isDemoAsync = ref.watch(demoModeNotifierProvider);
Analise/lib/features/analise/presentation/providers/analise_provider.dart:76:    final bool isDemoOn = ((isDemoAsync.valueOrNull ??
Analise/lib/features/analise/presentation/providers/analise_provider.dart:77:            await ref.watch(demoModeNotifierProvider.future)) ==
Analise/lib/features/analise/presentation/providers/analise_provider.dart:85:    if (!isDemoOn) {
Analise/lib/features/analise/presentation/providers/analise_provider.dart:90:    // Demo mode ativo: carregar seeds locais uma única vez
Analise/lib/features/analise/presentation/providers/analise_provider.dart:94:        .map((m) => m.copyWith(id: 'demo_${m.id}') as AnaliseSolo)
Analise/lib/features/analise/presentation/widgets/analise_card_widget.dart:18:    final isDemo = analise.id.startsWith('demo_');
Analise/lib/features/analise/presentation/widgets/analise_card_widget.dart:116:    if (!isDemo) return card;
Analise/lib/features/config/application/providers/demo_mode_provider.dart:2:import 'package:soloforte/features/config/data/datasources/demo_mode_hive_datasource.dart';
Analise/lib/features/config/application/providers/demo_mode_provider.dart:6:final demoModeHiveDatasourceProvider = Provider<DemoModeHiveDatasource>((ref) {
Analise/lib/features/config/application/providers/demo_mode_provider.dart:7:  return DemoModeHiveDatasource();
Analise/lib/features/config/application/providers/demo_mode_provider.dart:12:class DemoModeNotifier extends AsyncNotifier<bool> {
Analise/lib/features/config/application/providers/demo_mode_provider.dart:15:    return ref.read(demoModeHiveDatasourceProvider).isEnabled();
Analise/lib/features/config/application/providers/demo_mode_provider.dart:21:    await ref.read(demoModeHiveDatasourceProvider).setEnabled(next);
```

### H.1 demo_mode_provider
Comando:
```bash
cat "Analise/lib/features/config/application/providers/demo_mode_provider.dart"
```
Output real:
```
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/data/datasources/demo_mode_hive_datasource.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final demoModeHiveDatasourceProvider = Provider<DemoModeHiveDatasource>((ref) {
  return DemoModeHiveDatasource();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class DemoModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(demoModeHiveDatasourceProvider).isEnabled();
  }

  Future<void> toggle() async {
    final current = await future;
    final next = !current;
    await ref.read(demoModeHiveDatasourceProvider).setEnabled(next);
    state = AsyncData(next);
    ref.invalidateSelf();
  }
}

final demoModeNotifierProvider = AsyncNotifierProvider<DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);
```

### H.1 demo_mode_hive_datasource
Comando:
```bash
cat "Analise/lib/features/config/data/datasources/demo_mode_hive_datasource.dart"
```
Output real:
```
import 'package:hive_flutter/hive_flutter.dart';

/// Datasource local para o toggle de "Análises de Demonstração".
/// Usa Hive — offline-first, persiste entre sessões.
class DemoModeHiveDatasource {
  static const String _boxName = 'demo_mode_box';
  static const String _key = 'analise_demo_mode_enabled';

  Future<bool> isEnabled() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_key, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, value);
  }
}
```

### H.1 find README/DEMO/APP_STORE
Comando:
```bash
find Analise -name "README*" -o -name "DEMO*" -o -name "APP_STORE*" 2>/dev/null | head -5
```
Output real:
```
Analise/infra/observability/README.md
Analise/docs/release/build46/README.md
Analise/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
Analise/ios/Pods/FirebaseRemoteConfigInterop/README.md
Analise/ios/Pods/FirebaseCrashlytics/Crashlytics/README.md
```

### H.1 busca adicional em docs .md
Comando:
```bash
grep -rn "demo@\|cadernosolo\|apple review\|reviewer\|testflight" Analise --include="README*" --include="*.md" | head -20
```
Output real:
```
Analise/docs/release/build46/README.md:15:- `testflight_post_upload_checklist.md`: checklist exato do que validar/marcar no TestFlight apos o upload.
Analise/docs/release/build46/README.md:19:- `templates/testflight_monitoring_log_48h_TEMPLATE.md`
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:32:- Conta de demonstração funcional para o reviewer Apple
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:70:A Apple exige conta de demonstração para qualquer app com login. Sem ela, o reviewer não acessa as funcionalidades e a rejeição é imediata.
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:72:**Ação:** Criar `demo@cadernosolo.com.br` no Firebase Console (sem código), logar no app com Build 46, salvar 2 análises completas com dados fictícios, documentar credenciais no `app_store_connect_pack.md`.
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:144:| **Critério** | Conta demo criada no Firebase Auth, funcional sem convite. Pelo menos 2 análises completas salvas para o reviewer navegar. |
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:145:| **Aceite** | Criar `demo@cadernosolo.com.br`, testar login em device com Build 46 e documentar credenciais. |
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:171:- `testflight_post_upload_checklist.md`
Analise/docs/release/build46/PRD_Publicacao_AppStore_Build46.md:181:- TestFlight Overview: https://developer.apple.com/testflight/
Analise/docs/release/build46/templates/testflight_monitoring_log_48h_TEMPLATE.md:3:Preencher este arquivo como evidencia. Recomendacao: salvar uma copia com nome `testflight_monitoring_log_48h_build46_YYYY-MM-DD.md`.
Analise/docs/release/build46/monitoring_Tplus_plan.md:18:- Log preenchido: `templates/testflight_monitoring_log_48h_TEMPLATE.md` (criar copia preenchida).
Analise/PROMPT/RESULTADO_AUDITORIA.md:2059:- Comando: `grep -rn "demo@cadernosolo\|demo@\|conta.*demo" Analise/lib --include="*.dart" | head -5`
Analise/PROMPT/RESULTADO_AUDITORIA.md:2137:7. `/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/lib` — conta demo `demo@cadernosolo.com.br` não encontrada por grep.
```

### H.1 trecho app_store_connect_pack
Comando:
```bash
sed -n '80,100p' Analise/docs/release/app_store_connect_pack.md
```
Output real:
```
- Phone Number: `preencher`
- Email Address: `preencher`

### Sign-in required?
- `Yes` (app usa autenticação)

### Demo account (se solicitado no review)
- Username: `preencher`
- Password: `preencher`

### Notes for Review (copiar/colar)
`O app exige autenticação para acesso aos dados de análise.
Principais fluxos para validação:
1) Login/Cadastro
2) Nova Análise (incluindo captura de GPS)
3) Salvamento e listagem de análises
4) Histórico de recomendações

A captura de localização é opcional e ocorre apenas quando o usuário toca no botão de captura de GPS.`

---
```

### I. top 10 maiores arquivos não gerados
Comando:
```bash
find Analise/lib -name "*.dart" ! -name "*.freezed.dart" ! -name "*.g.dart" -exec wc -l {} + | sort -rn | head -10
```
Output real:
```
   39978 total
    3558 Analise/lib/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart
    2090 Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart
    1952 Analise/lib/data/culturas_data.dart
    1162 Analise/lib/domain/usecases/recomendacao_engine.dart
    1057 Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart
     993 Analise/lib/features/analise/domain/validation/analise_data_contract.dart
     967 Analise/lib/features/auth/presentation/login/login_page.dart
     960 Analise/lib/data/lab_templates/lab_pdf_parser.dart
     905 Analise/lib/features/config/presentation/config_page.dart
```

### I. count widgets calibracao_page
Comando:
```bash
grep -c "Widget build\|class.*Widget\|StatelessWidget\|StatefulWidget" "Analise/lib/features/laboratorio/presentation/calibracao/calibracao_page.dart"
```
Output real:
```
6
```

### I. count widgets potassio_card_widget
Comando:
```bash
grep -c "Widget build\|class.*Widget\|StatelessWidget\|StatefulWidget" "Analise/lib/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart"
```
Output real:
```
3
```

### I. count widgets fosforo_card_widget
Comando:
```bash
grep -c "Widget build\|class.*Widget\|StatelessWidget\|StatefulWidget" "Analise/lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart"
```
Output real:
```
5
```

### I. count widgets recomendacao_page
Comando:
```bash
grep -c "Widget build\|class.*Widget\|StatelessWidget\|StatefulWidget" "Analise/lib/features/laboratorio/presentation/recomendacao/recomendacao_page.dart"
```
Output real:
```
12
```
