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
    SharedPreferences.setMockInitialValues({'username': 'TestUser'});

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

    await tester.pumpAndSettle();

    expect(find.text('Hello, TestUser'), findsOneWidget);

    expect(find.text('Create New Journal'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline_outlined), findsOneWidget);

    expect(find.text('View Journal'), findsOneWidget);
    expect(find.byIcon(Icons.view_module_sharp), findsOneWidget);


    await tester.tap(find.text('Create New Journal'));
    await tester.pumpAndSettle();
    expect(find.byType(NewJournal),
        findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Journal'));
    await tester.pumpAndSettle();
    expect(find.byType(ViewJournal),
        findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
