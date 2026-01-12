// Imports the Flutter Driver API.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:idiomatic_translation_front/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test', (WidgetTester tester) async {
    // Start the app.
    app.main();

    // Wait for the app to settle.
    await tester.pumpAndSettle();

    // Verify that the initial text is present.
    // This assumes your app starts with a title 'Flutter Demo Home Page'.
    // You should change 'Flutter Demo Home Page' to the actual title of your app.
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);

    // Example of tapping the '+' icon and verifying the counter.
    // You can adapt this to your app's functionality.
    //
    // Find the floating action button and tap it.
    // await tester.tap(find.byTooltip('Increment'));
    // await tester.pumpAndSettle();
    //
    // Verify the counter has incremented.
    // expect(find.text('1'), findsOneWidget);
  });
}
