import 'package:flutter/material.dart';
import 'package:untitled/JourneyMap.dart';
import 'package:untitled/ViewJournal.dart';
import 'journal_entry.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<JournalEntry> journalEntries = [];
  int journalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  void _toggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        print("File content: $fileContent");

        List<dynamic> data = [];
        if (fileContent.trim().isNotEmpty) {
          try {
            data = jsonDecode(fileContent);
          } catch (e) {
            print("Error parsing JSON: $e");
            data = [];
          }
        }

        setState(() {
          journalEntries = data.map((entry) {
            return JournalEntry(
              title: entry['title'] ?? 'Untitled',
              content: entry['content'] ?? '',
              imagePaths:
                  List<String>.from(jsonDecode(entry['imagePaths'] ?? '[]')),
              locationName: entry['locationName'],
              mood: entry['mood'],
              date: entry['date'] != null
                  ? DateTime.parse(entry['date'])
                  : DateTime.now(),
            );
          }).toList();
          journalCount = journalEntries.length;
        });
      } else {
        print("Journal file does not exist at ${journalFile.path}");
        setState(() {
          journalEntries = [];
          journalCount = 0;
        });
      }
    } catch (e, stackTrace) {
      print("Error loading journal entries: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        journalEntries = [];
        journalCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
    final backgroundColor =
        themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColors =
        themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    final buttonColors =
        themeMode == ThemeMode.dark ? Colors.grey[900] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'HomePage',
          style: TextStyle(
              color: textColors, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            themeMode == ThemeMode.dark ? Colors.black : Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.light_mode,
                color:
                    themeMode == ThemeMode.dark ? Colors.yellow : Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 30.0),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade900,
                      blurRadius: 2,
                      spreadRadius: 10,
                    ),
                  ], color: Colors.green[100]),
                  child: Center(
                    child: Text(
                      "Total Journals: $journalCount",
                      style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/NewJournal').then((_) {
                        _loadJournalEntries();
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                      color: Colors.amber,
                    ),
                    label: Text(
                      "Create New Journal",
                      style: TextStyle(
                          color: textColors,
                          fontSize: 22,
                          fontWeight: FontWeight.w400),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 19),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: buttonColors),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  width: 300,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewJournal()),
                      );
                    },
                    icon: const Icon(
                      Icons.view_module_sharp,
                      color: Colors.amber,
                    ),
                    label: Text(
                      "View Journal",
                      style: TextStyle(
                        color: textColors,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 19),
                        backgroundColor: buttonColors,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  width: 300,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JourneyMap()),
                      );
                    },
                    icon: const Icon(
                      Icons.map,
                      color: Colors.amber,
                    ),
                    label: Text(
                      "My Journies",
                      style: TextStyle(
                        color: textColors,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 19),
                        backgroundColor: buttonColors,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
