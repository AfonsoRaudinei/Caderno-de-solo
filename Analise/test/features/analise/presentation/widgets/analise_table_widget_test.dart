import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_table_widget.dart';

Future<void> _setLargeSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 5200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Map<String, dynamic> _baseAnalise({
  String talhao = 'T-01',
  String numeroAmostra = 'A-01',
  String k = '0.31',
  String phCaCl2 = '5.4',
  String latitude = '',
  String longitude = '',
}) {
  return {
    'talhao': talhao,
    'numeroAmostra': numeroAmostra,
    'profundidade': '0-20',
    'phCaCl2': phCaCl2,
    'k': k,
    'ca': '3.1',
    'mg': '1.2',
    'latitude': latitude,
    'longitude': longitude,
  };
}

Future<void> _pumpTable(
  WidgetTester tester, {
  required String laboratorio,
  required List<Map<String, dynamic>> analises,
  ValidationSnapshot validation = ValidationSnapshot.empty,
  void Function(int index, String campo, String valor)? onCampoChanged,
  Future<void> Function(int index)? onGpsClicked,
  VoidCallback? onAddAnalise,
  void Function(int index)? onRemoveAnalise,
  String? highlightedCellKey,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: AnaliseTableWidget(
              analises: analises,
              derivados: List.generate(
                analises.length,
                (_) => const <String, double>{},
              ),
              onCampoChanged: onCampoChanged ?? (_, __, ___) {},
              onGpsClicked: onGpsClicked,
              onAddAnalise: onAddAnalise,
              onRemoveAnalise: onRemoveAnalise,
              laboratorio: laboratorio,
              validation: validation,
              highlightedCellKey: highlightedCellKey,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _cellField(String key) {
  return find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(TextField),
  );
}

void main() {
  group('AnaliseTableWidget - render por laboratório', () {
    testWidgets('Sellar exibe campos amplos (pH Água, S 20-40, Ni)',
        (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [_baseAnalise()],
      );

      expect(find.text('pH Água'), findsOneWidget);
      expect(find.text('S 20-40'), findsOneWidget);
      expect(find.text('Ni'), findsOneWidget);
    });

    testWidgets('Exata Brasil oculta campo não suportado S 20-40',
        (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'Exata Brasil',
        analises: [_baseAnalise()],
      );

      expect(find.text('P Resina'), findsOneWidget);
      expect(find.text('S 20-40'), findsNothing);
    });

    testWidgets('IBRA oculta pH Água e mantém P Resina', (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'IBRA',
        analises: [_baseAnalise()],
      );

      expect(find.text('pH Água'), findsNothing);
      expect(find.text('P Resina'), findsOneWidget);
    });

    testWidgets('MB oculta pH Água, S 20-40 e Ni', (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'MB Agronegócios',
        analises: [_baseAnalise()],
      );

      expect(find.text('pH Água'), findsNothing);
      expect(find.text('S 20-40'), findsNothing);
      expect(find.text('Ni'), findsNothing);
    });
  });

  group('AnaliseTableWidget - edição e coluna', () {
    testWidgets('campo numérico limita entrada a 7 dígitos', (tester) async {
      await _setLargeSurface(tester);
      String? captured;
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [_baseAnalise()],
        onCampoChanged: (_, campo, valor) {
          if (campo == 'k') captured = valor;
        },
      );

      await tester.enterText(_cellField('k_0'), '123456789');
      await tester.pump();

      expect(find.text('1234567'), findsOneWidget);
      expect(captured, '1234567');
    });

    testWidgets('edição em A2 atualiza índice e campo corretos',
        (tester) async {
      await _setLargeSurface(tester);
      int? index;
      String? campo;
      String? valor;
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [
          _baseAnalise(talhao: 'T-01', numeroAmostra: 'A-01'),
          _baseAnalise(talhao: 'T-02', numeroAmostra: 'A-02'),
        ],
        onCampoChanged: (i, c, v) {
          index = i;
          campo = c;
          valor = v;
        },
      );

      await tester.enterText(_cellField('talhao_1'), 'T-99');
      await tester.pump();

      expect(index, 1);
      expect(campo, 'talhao');
      expect(valor, 'T-99');
    });
  });

  group('AnaliseTableWidget - validação visual', () {
    testWidgets('exibe badge no header e ícone de erro em célula',
        (tester) async {
      await _setLargeSurface(tester);
      const validation = ValidationSnapshot(
        version: analiseDataContractVersion,
        labId: 'sellar',
        issues: [
          ValidationIssue(
            columnIndex: 1,
            fieldKey: 'k',
            fieldLabel: 'K',
            code: 'ERR_OUT_OF_RANGE_MAX',
            message: 'Valor acima do máximo.',
            severity: ValidationSeverity.error,
            currentValue: '99',
          ),
        ],
        normalizedColumns: [
          <String, String>{},
          <String, String>{},
        ],
      );

      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [
          _baseAnalise(k: '0.3'),
          _baseAnalise(talhao: 'T-02', numeroAmostra: 'A-02', k: '99'),
        ],
        validation: validation,
      );

      expect(find.text('A2'), findsOneWidget);
      expect(find.text('1E'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsWidgets);

      final tooltip = tester.widget<Tooltip>(
        find.descendant(
          of: find.byKey(const ValueKey('k_1')),
          matching: find.byType(Tooltip),
        ),
      );
      expect(tooltip.message, contains('A2 > K'));
    });

    testWidgets('destaca célula navegada com borda primária', (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [_baseAnalise()],
        highlightedCellKey: '0:k',
      );

      final animated = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const ValueKey('k_0')),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final box = animated.decoration! as BoxDecoration;
      final border = box.border! as Border;
      expect(border.bottom.color, AppColors.primary);
    });
  });

  group('AnaliseTableWidget - ações da grade', () {
    testWidgets('aciona adicionar e remover coluna', (tester) async {
      await _setLargeSurface(tester);
      var addCalls = 0;
      int? removedIndex;
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [
          _baseAnalise(),
          _baseAnalise(talhao: 'T-02', numeroAmostra: 'A-02'),
        ],
        onAddAnalise: () => addCalls++,
        onRemoveAnalise: (i) => removedIndex = i,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(addCalls, 1);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pump();
      expect(removedIndex, 0);
    });

    testWidgets('não mostra botão adicionar ao atingir máximo de 6 colunas',
        (tester) async {
      await _setLargeSurface(tester);
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: List.generate(
          6,
          (i) => _baseAnalise(
            talhao: 'T-${i + 1}',
            numeroAmostra: 'A-${i + 1}',
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('aciona callback de GPS por coluna correta', (tester) async {
      await _setLargeSurface(tester);
      int? gpsIndex;
      await _pumpTable(
        tester,
        laboratorio: 'Sellar',
        analises: [
          _baseAnalise(latitude: '-16.12', longitude: '-48.99'),
          _baseAnalise(talhao: 'T-02', numeroAmostra: 'A-02'),
        ],
        onGpsClicked: (index) async => gpsIndex = index,
      );

      expect(find.byIcon(Icons.gps_fixed), findsOneWidget);
      expect(find.byIcon(Icons.gps_not_fixed), findsOneWidget);

      await tester.tap(find.byTooltip('Capturar GPS').at(1));
      await tester.pump();
      expect(gpsIndex, 1);
    });
  });
}
