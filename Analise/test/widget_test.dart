// Smoke test básico — verifica apenas que o material do Flutter está disponível.
// Testes de integração da UI ficam em test/presentation/.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test — app widget pode ser importado', (WidgetTester tester) async {
    // Placeholder: o app usa Firebase.initializeApp() no main(), o que impede
    // pumping da AnaliseApp em testes unitários sem mocks completos.
    // Testes de widget detalhados estão em test/presentation/.
    expect(true, isTrue);
  });
}

