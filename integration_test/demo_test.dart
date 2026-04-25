import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:questboard/main.dart' as app;
import 'package:questboard/data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Demo: Intro -> Sign Up -> Logout -> Login -> Create Quest', (tester) async {
    // Clear DB for a fresh start
    await DatabaseHelper.instance.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    app.main();
    await tester.pump(const Duration(seconds: 1));
    
    // Wait for the intro screen to appear (bypass loading)
    print('Waiting for Intro Screen...');
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();

    // 1. Intro Screen
    print('Intro Screen: Page 1...');
    expect(find.text('WELCOME ADVENTURER'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    print('Intro Screen: Page 2...');
    expect(find.text('MASTER YOUR FOCUS'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    print('Intro Screen: Page 3...');
    expect(find.text('RISE TO GLORY'), findsOneWidget);
    await tester.tap(find.text('BEGIN YOUR LEGEND'));
    await tester.pumpAndSettle();

    // 2. Auth Screen - Sign Up
    print('Auth Screen: Switching to Sign Up...');
    await tester.tap(find.textContaining('JOIN NOW', findRichText: true));
    await tester.pumpAndSettle();

    print('Entering credentials for Sign Up...');
    final demoEmail = 'hero@questboard.com';
    final demoPass = 'password123';
    
    await tester.enterText(find.byType(TextField).at(0), demoEmail);
    await tester.enterText(find.byType(TextField).at(1), demoPass);
    await tester.pumpAndSettle();

    await tester.tap(find.text('FORGE ACCOUNT'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // 3. Onboarding Screen
    print('Onboarding...');
    final nameField = find.byType(TextField).first;
    await tester.tap(nameField);
    await tester.enterText(nameField, 'Quest Hero');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // 4. Dashboard - Verify and Logout
    print('Dashboard: Verifying name...');
    expect(find.text('QUEST HERO'), findsOneWidget); // Onboarding uppercase it? No, but let's check
    // Wait, let's use findsOneWidget for just Hero if needed, or check what I wrote.
    // I'll just check if it contains 'Hero'.
    expect(find.textContaining('HERO'), findsOneWidget);
    
    print('Logging out...');
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5. Auth Screen - Login
    print('Logging back in...');
    await tester.enterText(find.byType(TextField).at(0), demoEmail);
    await tester.enterText(find.byType(TextField).at(1), demoPass);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('ENTER REALM'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // 6. Create Quest
    print('Creating quest...');
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Demo Quest');
    await tester.enterText(find.byType(TextField).at(1), 'Created during the demo.');
    await tester.pumpAndSettle();

    final forgeBtn = find.text('ACCEPT QUEST');
    await tester.ensureVisible(forgeBtn);
    await tester.tap(forgeBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Final verification on Dashboard
    print('Final verification...');
    expect(find.text('Demo Quest'), findsOneWidget);
    print('Demo Completed Successfully!');
  });
}
