import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/models/micronutrientes_calibracao.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/micronutrientes_card_widget.dart';

void main() {
  testWidgets('exibe NC visível e apenas elementos selecionados no grupo',
      (tester) async {
    final data = migrateMicrosParametros({
      'grupos': [
        {
          'id': 'g1',
          'nome': 'Mistura foliar vegetativa',
          'via': 'Foliar',
          'elementos': ['B', 'Mn'],
          'eficienciaFoliar': 80,
          'fonteFoliar': 'Mix',
        },
      ],
      'elementos': {
        'B': {
          ...defaultElementoMicro('B'),
          'ncSolo': 0.90,
        },
        'Mn': {
          ...defaultElementoMicro('Mn'),
          'ncSolo': 6.0,
        },
      },
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MicronutrientesCardWidget(
                draftKey: 'draft-test',
                initialData: data,
                isExpanded: true,
                onToggle: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mistura foliar vegetativa'), findsOneWidget);
    expect(find.byKey(const Key('subcard_micro_g1-B')), findsOneWidget);
    expect(find.byKey(const Key('subcard_micro_g1-Mn')), findsOneWidget);
    expect(find.byKey(const Key('subcard_micro_g1-Zn')), findsNothing);

    expect(find.byKey(const Key('nc_visivel_g1-B')), findsOneWidget);
    expect(find.textContaining('Nível crítico:'), findsWidgets);
    expect(find.textContaining('0,90'), findsWidgets);
  });

  testWidgets('criar grupo adiciona card independente', (tester) async {
    Map<String, dynamic>? emitted;
    final data = migrateMicrosParametros({'grupos': <Map<String, dynamic>>[]});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MicronutrientesCardWidget(
                draftKey: 'draft-test',
                initialData: data,
                isExpanded: true,
                onToggle: () {},
                onChanged: (value) => emitted = value,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('btn_criar_grupo_micros')));
    await tester.pumpAndSettle();

    expect(emitted, isNotNull);
    expect(gruposFromMicros(emitted!), hasLength(1));
  });
}
