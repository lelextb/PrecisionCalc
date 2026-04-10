// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calc_architect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full calculator flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Press digits
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.pump();

    // Press +
    await tester.tap(find.text('+'));
    await tester.pump();

    // Press 3
    await tester.tap(find.text('3'));
    await tester.pump();

    // Press =
    await tester.tap(find.text('='));
    await tester.pump();

    // Verify result 15
    expect(find.text('15'), findsOneWidget);
  });
}