import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/main.dart';
import 'package:untitled/providers/theme_provider.dart';
import 'package:untitled/MainScreen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(
        {'isLoggedIn': true, 'username': 'testuser'});
  });

  testWidgets('Travel Journal app launches correctly',
      (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: TravelJournal(
          initialRoute: '/MainScreen',
        ),
      ),
    );

    expect(find.byType(MainScreen), findsOneWidget);
  });

  testWidgets('Can navigate between screens', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: TravelJournal(
          initialRoute: '/MainScreen',
        ),
      ),
    );
  });

  testWidgets('Theme provider works', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: TravelJournal(
          initialRoute: '/MainScreen',
        ),
      ),
    );
  });
}
