import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_global_summit_21/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_driver/flutter_driver.dart' as fd;
import 'package:path_provider/path_provider.dart';
import 'package:vm_service/vm_service.dart' as vm;

void main() {
  final WidgetsBinding unCastBinding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late final IntegrationTestWidgetsFlutterBinding binding;

  if (unCastBinding is IntegrationTestWidgetsFlutterBinding) {
    binding = unCastBinding;
  } else {
    throw StateError('$unCastBinding != IntegrationTestWidgetsFlutterBinding');
  }

  testWidgets('User journey test', (WidgetTester tester) async {
    const int userCount = 1000;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(userCount: userCount));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    // Trace the interacting and refreshing of the screen
    // Basically build being call for 99 times.
    final vm.Timeline homeTimeLine = await binding.traceTimeline(() async {
      for (int i = 0; i < 99; i++) {
        // Tap the '+' icon and trigger a frame.
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }
    });

    expect(find.text('1'), findsNothing);
    expect(find.text('100'), findsOneWidget);

    // Open the users page.
    await tester.tap(find.byKey(openUsersPage));
    // Wait for the page to fully display.
    await tester.pumpAndSettle();

    const int user = 645;

    const ValueKey<int> tileKey = ValueKey<int>(user);

    // Trace the scrolling throw a 1000 element list until element 645 founded.
    final vm.Timeline scrollTimeLine = await binding.traceTimeline(() async {
      await tester.scrollUntilVisible(
        find.byKey(tileKey),
        100,
        maxScrolls: 1000,
      );
    });

    expect(find.byKey(tileKey), findsOneWidget);

    await tester.tap(find.byKey(tileKey));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('100'), findsOneWidget);

    // Optionally, write the entire timeline to disk in a json format. This
    // file can be opened in the Chrome browser's tracing tools found by
    // navigating to chrome://tracing.
    final fd.Timeline homeSummary = fd.Timeline.fromJson(homeTimeLine.toJson());

    final fd.Timeline scrollingSummary =
        fd.Timeline.fromJson(scrollTimeLine.toJson());

    if (Platform.isAndroid) {
      final Directory? timelineDir = await getExternalStorageDirectory();

      await fd.TimelineSummary.summarize(homeSummary).writeTimelineToFile(
        'home',
        destinationDirectory: timelineDir!.path,
        pretty: true,
      );

      await fd.TimelineSummary.summarize(scrollingSummary).writeTimelineToFile(
        'scrolling',
        destinationDirectory: timelineDir.path,
        pretty: true,
      );
    }
  });
}
