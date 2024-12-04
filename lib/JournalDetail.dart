import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:untitled/journal_entry.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class JournalDetail extends StatefulWidget {
  final JournalEntry entry;

  const JournalDetail({super.key, required this.entry});

  @override
  _JournalDetailState createState() => _JournalDetailState();
}

class _JournalDetailState extends State<JournalDetail> {
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _resolveLocationName();
  }

  Future<void> _saveEditedJournal(
      String newTitle, String newContent, String? newMood) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        List<dynamic> journals = jsonDecode(fileContent);

        for (var i = 0; i < journals.length; i++) {
          if (journals[i]['date'] == widget.entry.date.toIso8601String()) {
            journals[i]['title'] = newTitle;
            journals[i]['content'] = newContent;
            journals[i]['mood'] = newMood;
            break;
          }
        }

        await journalFile.writeAsString(jsonEncode(journals));

        setState(() {
          widget.entry.title = newTitle;
          widget.entry.content = newContent;
          widget.entry.mood = newMood;
        });
      }
    } catch (e) {
      print('Error saving edited journal: $e');
      rethrow;
    }
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: widget.entry.title);
    final contentController = TextEditingController(text: widget.entry.content);
    final moodController = TextEditingController(text: widget.entry.mood ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title:
        Text('Edit Journal Entry', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: moodController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mood',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save', style: TextStyle(color: Colors.green[300])),
            onPressed: () async {
              await _saveEditedJournal(
                titleController.text,
                contentController.text,
                moodController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Journal updated successfully')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _resolveLocationName() async {
    if (widget.entry.locationName != null &&
        widget.entry.locationName!.isNotEmpty) {
      setState(() {
        _locationName = widget.entry.locationName ?? 'No location set';
      });
      return;
    }

    if (widget.entry.latitude != null && widget.entry.longitude != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.entry.latitude!,
          widget.entry.longitude!,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _locationName =
            '${place.locality}, ${place.administrativeArea}, ${place.country}';
          });
        } else {
          setState(() {
            _locationName = 'Unknown location';
          });
        }
      } catch (e) {
        setState(() {
          _locationName = 'Unable to fetch location';
        });
      }
    } else {
      setState(() {
        _locationName = 'Location not available';
      });
    }
  }

  Widget _buildImageGallery(List<String> imagePaths) {
    if (imagePaths.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imagePaths.length,
        itemBuilder: (context, imageIndex) {
          return InstaImageViewer(
            child: Container(
              width: 150,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(imagePaths[imageIndex])),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(widget.entry.title,
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.entry.imagePaths.isNotEmpty)
                _buildImageGallery(widget.entry.imagePaths),
              const SizedBox(height: 16),
              Text(
                widget.entry.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.entry.mood != null &&
                  widget.entry.mood!.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.mood, color: Colors.yellow),
                    const SizedBox(width: 8),
                    Text(
                      'Mood: ${widget.entry.mood}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (widget.entry.locationName != null &&
                  widget.entry.locationName!.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${widget.entry.locationName!}',
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    )
                  ],
                ),
              const SizedBox(height: 16),
              Text(
                widget.entry.content,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
