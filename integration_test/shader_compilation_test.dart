import 'package:flutter/material.dart';
import 'package:flutter_global_summit_21/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Counter app SKSL test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(userCount: 1000));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Open the users page.
    await tester.tap(find.byKey(openUsersPage));
    // Wait for the page to fully display.
    await tester.pumpAndSettle();

    const int user = 645;

    const ValueKey<int> tileKey = ValueKey<int>(user);

    await tester.scrollUntilVisible(
      find.byKey(tileKey),
      100,
      maxScrolls: 1000,
    );

    expect(find.byKey(tileKey), findsOneWidget);

    await tester.tap(find.byKey(tileKey));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1'), findsNothing);
  });
}
