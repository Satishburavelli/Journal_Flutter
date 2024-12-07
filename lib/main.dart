import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/LoginPage.dart';
import 'package:untitled/MainScreen.dart';
import 'package:untitled/NewJournal.dart';
import 'package:untitled/ViewJournal.dart';
import 'package:untitled/JourneyMap.dart';
import 'package:untitled/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: TravelJournal(
        initialRoute: isLoggedIn ? '/MainScreen' : '/LoginPage',
      ),
    ),
  );
}

class TravelJournal extends StatelessWidget {
  final String initialRoute;

  const TravelJournal({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Travel Journal',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: {
        '/LoginPage': (context) => const LoginPage(),
        '/MainScreen': (context) => const MainScreen(),
        '/NewJournal': (context) => NewJournal(),
        '/ViewJournal': (context) => ViewJournal(),
        '/JourneyMap': (context) => JourneyMap(),
      },
    );
  }
}

// Example logout function
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
  await prefs.setBool('isLoggedIn', false);

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/LoginPage',
    (Route<dynamic> route) => false,
  );
}
