import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'journal_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/JournalDetail.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';

class ViewJournal extends StatefulWidget {
  final List<JournalEntry>? entries;
  const ViewJournal({super.key, this.entries});

  @override
  State<ViewJournal> createState() => _ViewJournalState();
}

class _ViewJournalState extends State<ViewJournal> {
  List<JournalEntry> entries = [];
  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        print('File content: $fileContent');
        final List<dynamic> data = jsonDecode(fileContent);

        setState(() {
          entries = data.map((entry) {
            List<String> imagePaths = [];
            if (entry.containsKey('imagePaths')) {
              if (entry['imagePaths'] is String) {
                imagePaths = List<String>.from(jsonDecode(entry['imagePaths']));
              } else {
                imagePaths = List<String>.from(entry['imagePaths']);
              }
              print('Image paths for entry "${entry['title']}": $imagePaths');
            }

            return JournalEntry(
              title: entry['title'] ?? 'Untitled',
              content: entry['content'] ?? 'No content',
              imagePaths: imagePaths,
              locationName: entry['location'] ?? '',
              mood: entry['mood'] ?? '',
              date: entry['date'] != null
                  ? DateTime.parse(entry['date'])
                  : DateTime.now(),
            );
          }).toList();
        });
      } else {
        print('journals.json file does not exist.');
      }
    } catch (e) {
      print('Error loading journals: $e');
    }
  }

  Future<void> _deleteJournal(int index) async {
    setState(() {
      entries.removeAt(index);
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      final updatedData = entries.map((entry) {
        return {
          'title': entry.title,
          'content': entry.content,
          'imagePath': entry.imagePaths,
        };
      }).toList();

      await journalFile.writeAsString(jsonEncode(updatedData));
      print("Journal Entry Deleted.");
    } catch (e) {
      print("error deleting the journal");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
    final backgroundColor =
        themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColors =
        themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    final cardColor =
        themeMode == ThemeMode.dark ? Colors.grey[900] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'View Journal',
          style: TextStyle(color: textColors),
        ),
        iconTheme: IconThemeData(color: textColors),
      ),
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: entries.isEmpty
            ? Center(child: Text("No journals yet"))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalDetail(entry: entry),
                          ));
                    },
                    child: Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.imagePaths.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(File(entry.imagePaths[0])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.green.shade300,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      entry.content.length > 50
                                          ? '${entry.content.length > 50}'
                                          : entry.content,
                                      style: TextStyle(color: Colors.white),
                                    )),
                                    if (entry.content.length > 50)
                                      Text(
                                        'View More....',
                                        style:
                                            TextStyle(color: Colors.blue[300]),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteJournal(index);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
