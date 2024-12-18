import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untitled/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': true,
      'username': 'testuser',
    });
  });

  testWidgets('App launches and renders MainScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: app.TravelJournal(initialRoute: '/MainScreen'),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(MaterialApp), findsOneWidget);

    tester.allWidgets.forEach((widget) {
      print('Widget Type: ${widget.runtimeType}');
    });
  });

  testWidgets('Diagnostic print of widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: app.TravelJournal(initialRoute: '/MainScreen'),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 5));

    void printWidgetTree(Element element, [int indent = 0]) {
      print('${'  ' * indent}${element.widget.runtimeType}');
      element.visitChildren((child) {
        if (child is Element) {
          printWidgetTree(child, indent + 1);
        }
      });
    }

    printWidgetTree(tester.element(find.byType(MaterialApp)));
  });
}
