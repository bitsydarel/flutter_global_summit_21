import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_global_summit_21/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_driver/flutter_driver.dart' as fd;
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

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
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

    final vm.Timeline homeTimeLine = await binding.traceTimeline(() async {
      for (int i = 0; i < 99; i++) {
        // Tap the '+' icon and trigger a frame.
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        if (i.isEven) {
          await tester.runAsync<void>(
            () => Future<void>.delayed(const Duration(milliseconds: 250)),
          );
        }
      }
    });

    expect(find.text('1'), findsNothing);
    expect(find.text('100'), findsOneWidget);

    await tester.tap(find.byKey(openUsersPage));
    await tester.pumpAndSettle();

    const int user = 645;

    const ValueKey<int> tileKey = ValueKey<int>(user);

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
    await tester.pump();

    expect(find.text('100'), findsOneWidget);

    // Optionally, write the entire timeline to disk in a json format. This
    // file can be opened in the Chrome browser's tracing tools found by
    // navigating to chrome://tracing.
    final fd.Timeline fdHomeTimeline =
        fd.Timeline.fromJson(homeTimeLine.toJson());

    final fd.Timeline fdScrollingTimeline =
        fd.Timeline.fromJson(scrollTimeLine.toJson());

    final Directory timelineDir = await getApplicationDocumentsDirectory();

    print(path.canonicalize(timelineDir.path));

    await fd.TimelineSummary.summarize(fdHomeTimeline).writeTimelineToFile(
      'home_timeline',
      destinationDirectory: timelineDir.path,
      pretty: true,
    );

    await fd.TimelineSummary.summarize(fdScrollingTimeline).writeTimelineToFile(
      'scrolling_timeline',
      destinationDirectory: timelineDir.path,
      pretty: true,
    );
  });
}
