import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_bottom_tab_bar.dart';

void main() {
  testWidgets('AppBottomTabBar renders items and dispatches taps',
      (tester) async {
    var selectedIndex = 1;
    var tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              bottomNavigationBar: AppBottomTabBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  tappedIndex = index;
                  setState(() => selectedIndex = index);
                },
                items: const [
                  AppBottomTabItem(
                    icon: Icons.contacts_outlined,
                    selectedIcon: Icons.contacts,
                    label: 'Clientes',
                  ),
                  AppBottomTabItem(
                    icon: Icons.science_outlined,
                    selectedIcon: Icons.science,
                    label: 'Análise',
                  ),
                  AppBottomTabItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'Config',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.byTooltip('Clientes'), findsOneWidget);
    expect(find.byTooltip('Análise'), findsOneWidget);
    expect(find.byTooltip('Config'), findsOneWidget);
    expect(find.byIcon(Icons.science), findsOneWidget);

    await tester.tap(find.byTooltip('Config'));
    await tester.pumpAndSettle();

    expect(tappedIndex, 2);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
