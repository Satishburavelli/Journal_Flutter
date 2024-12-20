import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/journal_entry.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/theme_provider.dart';

class NewJournal extends StatefulWidget {
  const NewJournal({super.key});
  @override
  State<NewJournal> createState() => _NewJournal();
}

class _NewJournal extends State<NewJournal> {
  final List<File> _images = [];
  String? _selectedLocation;
  LatLng? _selectedLatLng;
  String? LocationName;

  String? _selectedMood;
  final _customerMoodController = TextEditingController();
  final List<String> _moods = ['Happy', 'Excited', 'Fun', 'Peaceful', 'Sad'];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  Timer? _debounce;

  bool _isLoadingLocation = false;

  Future<void> _getImage(ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _images.add(File(pickedImage.path));
        });
      } else {
        print("NO image selected");
      }
    } catch (e) {
      print("Error selecting the image.");
    }
  }

  Future<void> _saveJournal() async {
    String title = _titleController.text;
    String content = _contentController.text;

    if (title.isEmpty || content.isEmpty || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please fill all required fields(Title,Description and Image)")),
      );
      return;
    }

    await _saveJournalEntry(title, content, _images);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Journal Saved")),
    );
    Navigator.pushNamed(context, '/MainScreen');
  }

  Future<void> _saveJournalEntry(
      String title, String content, List<File> images) async {
    try {
      List<String> imagePaths = [];

      final directory = await getApplicationDocumentsDirectory();
      for (var image in images) {
        final imagePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
        await image.copy(imagePath);
        imagePaths.add(imagePath);
      }

      double? latitude, longitude;
      String? locationName;

      String finalMood = '';
      if (_customerMoodController.text.isNotEmpty) {
        finalMood = _customerMoodController.text;
      } else {
        finalMood = _selectedMood ?? '';
      }

      if (_selectedLocation != null) {
        final locationParts = _selectedLocation!.split(',');
        try {
          latitude = double.parse(locationParts[0]);
          longitude = double.parse(locationParts[1]);
          locationName = _locationController.text;
        } catch (e) {
          print("Error parsing location");
        }
      }
      Map<String, dynamic> journalData = {
        'title': title,
        'content': content,
        'imagePaths': jsonEncode(imagePaths),
        'location': locationName ?? '',
        'latitude': latitude ?? 0.0,
        'longitude': longitude ?? 0.0,
        'name': _locationController.text,
        'mood': finalMood,
        'date': DateTime.now().toIso8601String(),
      };

      final journalFile = File('${directory.path}/journals.json');
      List<dynamic> existingData = [];

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        if (fileContent.trim().isNotEmpty) {
          existingData = jsonDecode(fileContent);
        }
      }

      existingData.add(journalData);

      await journalFile.writeAsString(jsonEncode(existingData));
      print("Jounral Data saved at ${journalFile.path}");
    } catch (e) {
      print("error saving journal: $e");
      throw e;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable location services")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permissions are permanently denied."),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Getting location...")),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName =
            "${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
        locationName = locationName.replaceAll(RegExp(r'^,\s*'), '');

        setState(() {
          _selectedLocation = "${position.latitude},${position.longitude}";
          _selectedLatLng = LatLng(position.latitude, position.longitude);
          _locationController.text = locationName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location updated successfully")),
        );
      }
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error getting location. Please try again.")),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _customerMoodController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
    final backgroundColor =
        themeMode == ThemeMode.dark ? Colors.black : Colors.white;
    final textColors =
        themeMode == ThemeMode.dark ? Colors.white : Colors.black;
    final hintColors =
        themeMode == ThemeMode.dark ? Colors.grey[700] : Colors.grey[400];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: textColors),
        backgroundColor: backgroundColor,
        title: Text(
          "NewJournal",
          style: TextStyle(fontSize: 24, color: textColors),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                style: TextStyle(fontSize: 20, color: textColors),
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Journal Title",
                  hintStyle: TextStyle(color: hintColors),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 6,
                controller: _contentController,
                style: TextStyle(fontSize: 20, color: textColors),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: hintColors),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Mood Tracker:",
                style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: textColors),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                dropdownColor: backgroundColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select a mood",
                  hintStyle: TextStyle(color: hintColors),
                ),
                value: _selectedMood,
                items: _moods.map((mood) {
                  return DropdownMenuItem(
                    value: mood,
                    child: Text(
                      mood,
                      style: TextStyle(color: textColors),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMood = value;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                style: TextStyle(color: textColors),
                controller: _customerMoodController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter a custom mood(optional)",
                  hintStyle: TextStyle(color: hintColors),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                style: TextStyle(color: textColors),
                controller: _locationController,
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce =
                      Timer(const Duration(milliseconds: 500), () async {
                    try {
                      List<Location> locations =
                          await locationFromAddress(value);
                      if (locations.isNotEmpty) {
                        Location location = locations.first;
                        setState(() {
                          _selectedLocation =
                              "${location.latitude},${location.longitude}";
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                            "No location found \"$value\"",
                            style: TextStyle(color: Colors.white),
                          )),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          "Error finding location: $e ",
                          style: TextStyle(color: Colors.grey[600]),
                        )),
                      );
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "Enter location:(eg: New York)",
                  hintStyle: TextStyle(color: hintColors),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                ),
                onPressed: _isLoadingLocation
                    ? null
                    : () async {
                        setState(() {
                          _isLoadingLocation = true;
                        });
                        await _getCurrentLocation();
                        setState(() {
                          _isLoadingLocation = false;
                        });
                      },
                child: _isLoadingLocation
                    ? CircularProgressIndicator(
                        color: Colors.grey,
                        backgroundColor: Colors.green,
                      )
                    : Text(
                        "Use GPS location",
                        style: TextStyle(color: Colors.black),
                      ),
              ),
              _selectedLocation != null
                  ? Text(
                      "Selected Location: $_selectedLocation",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              _images.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _images.map((image) {
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Image.file(image, height: 200, width: 200),
                              ),
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _images.remove(image);
                                      });
                                    },
                                  )),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Text(
                      "No images selected.",
                      style: TextStyle(color: textColors),
                    ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                ),
                onPressed: () => _getImage(ImageSource.gallery),
                child: Text(
                  "Select an image",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[100],
                ),
                onPressed: () => _getImage(ImageSource.camera),
                child: Text(
                  "Click a photo",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                ),
                onPressed: _saveJournal,
                child: Text(
                  "Save journal",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

