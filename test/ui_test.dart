import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/MainScreen.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/NewJournal.dart';
import 'package:untitled/ViewJournal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MainScreen UI Test', (WidgetTester tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({'username': 'TestUser'});

    // Build the widget for MainScreen with proper route configurations
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: const MainScreen(),
          routes: {
            '/NewJournal': (context) => NewJournal(),
            '/ViewJournal': (context) => ViewJournal(),
          },
        ),
      ),
    );

    // Wait for any animations to settle
    await tester.pumpAndSettle();

    // Check that the 'Hello, TestUser' text is displayed
    expect(find.text('Hello, TestUser'), findsOneWidget);

    // Check that the "Create New Journal" button is present
    expect(find.text('Create New Journal'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_outlined), findsOneWidget);

    // Check that the "View Journal" button is present
    expect(find.text('View Journal'), findsOneWidget);
    expect(find.byIcon(Icons.view_module_sharp), findsOneWidget);

    // Check that the "My Journies" button is present

    // Tap on the "Create New Journal" button and navigate to NewJournal screen
    await tester.tap(find.text('Create New Journal'));
    await tester.pumpAndSettle();
    expect(find.byType(NewJournal),
        findsOneWidget); // Verify navigation to NewJournal

    // Navigate back to MainScreen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on the "View Journal" button and navigate to ViewJournal screen
    await tester.tap(find.text('View Journal'));
    await tester.pumpAndSettle();
    expect(find.byType(ViewJournal),
        findsOneWidget); // Verify navigation to ViewJournal

    // Navigate back to MainScreen
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
