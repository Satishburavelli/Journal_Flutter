import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/JourneyMap.dart';
import 'package:untitled/LoginPage.dart';
import 'package:untitled/MainScreen.dart';
import 'package:untitled/NewJournal.dart';
import 'package:untitled/ViewJournal.dart';
import 'package:untitled/providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TravelJournal(),
    ),
  );
}

class TravelJournal extends StatelessWidget {
  const TravelJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Travel Journal',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
      routes: {
        '/MainScreen': (context) => const MainScreen(),
        '/NewJournal': (context) => NewJournal(),
        '/ViewJournal': (context) => ViewJournal(),
        '/JourneyMap': (context) => JourneyMap(),
      },
    );
  }
}
