import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:condokey/app.dart';
import 'package:condokey/providers/app_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders bottom nav tabs', (tester) async {
    final provider = AppProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const CondoKeyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Access'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Guests'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Home screen shows doors', (tester) async {
    final provider = AppProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const CondoKeyApp(),
      ),
    );
    await tester.pump();

    // First two cards are in viewport; others may be off-screen in test
    expect(find.text('Main Gate'), findsOneWidget);
    expect(find.text('Pool Gate'), findsOneWidget);
    // Confirm total door count loaded
    expect(provider.doors.length, 6);
  });

  testWidgets('Slide to open toggle changes button mode', (tester) async {
    final provider = AppProvider();
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const CondoKeyApp(),
      ),
    );
    await tester.pump();

    // Default: push button mode — Open buttons visible
    expect(find.text('Open'), findsWidgets);

    // Toggle slide mode
    await provider.setUseSlideToOpen(true);
    await tester.pump();

    // Slide mode: Open buttons gone, slide labels visible
    expect(find.text('Open'), findsNothing);
    expect(find.text('Slide to open'), findsWidgets);
  });
}
