import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:untitled/ViewJournal.dart';

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/journal_entry.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';

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
  final List<String> _moods = ['Calm', 'Peaceful', 'Happy', 'Sad', 'Excited'];
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
        const SnackBar(content: Text("Please fill all the fields")),
      );
      return;
    }

    await _saveJournalEntry(title, content, _images);

    // Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("JournalSaved")),
    );
    Navigator.pushNamed(context, '/MainScreen');
  }

  Future<List<JournalEntry>> _loadJournalEntries() async {
    final directory = await getApplicationDocumentsDirectory();
    final journalFile = File('${directory.path}/journals.json');
    if (!await journalFile.exists()) return [];

    final String fileContent = await journalFile.readAsString();
    final List<dynamic> data = jsonDecode(fileContent);
    return data.map((entry) {
      return JournalEntry(
        title: entry['title'],
        content: entry['content'],
        imagePaths:
            (jsonDecode(entry['imagePaths']) as List<dynamic>).isNotEmpty
                ? (jsonDecode(entry['imagePaths']) as List<dynamic>).first
                : '',
        locationName: entry['location']?['name'] ?? '',
        latitude: entry['latitude'],
        location: entry['location']?['coordinates'] ?? '',
        mood: entry['mood'] ?? '',
      );
    }).toList();
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
      //
      // String mood = _selectedMood ?? '';
      // if (_customerMoodController.text.isEmpty) {
      //   mood = _customerMoodController.text;
      // }
      double? latitude, longitude;
      String? locationName;

      String finalMood = '';
      // can be done using terenary operator
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
        // 'locationName': _locationController.text,  // Correctly store the location name
        'location': locationName?? '',
        'latitude':latitude?? 0.0,
        'longitude':longitude?? 0.0,// Store lat/long
        'name': _locationController.text,         // Store location name again
        'mood': finalMood,
      };


      final journalFile = File('${directory.path}/journals.json');
      List<dynamic> existingData = [];

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        if (fileContent.trim().isNotEmpty) {
          existingData = jsonDecode(fileContent);
        }
      }
      if (existingData is! List) {
        existingData = [];
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
        locationName = locationName.replaceAll(
            RegExp(r'^,\s*'), ''); // Remove leading comma if locality is empty

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
        const SnackBar(content: Text("Error getting location. Please try again.")),
      );
    }
  }


  // void _showMapPicker() async {
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.7,
  //       child: MapPicker(
  //         onLocationPicked: (location, address) {
  //           setState(() {
  //             _selectedLatLng = location;
  //             _locationController.text = address;
  //             _selectedLocation = "${location.latitude},${location.longitude}";
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text(
          "NewJournal",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                style: const TextStyle(fontSize: 20),
                controller: _titleController,
                decoration: InputDecoration(hintText: "Journal Title"),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 6,
                controller: _contentController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(hintText: "Description"),
              ),
              SizedBox(
                height: 20,
              ),

              Text(
                "Mood Tracker:",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),

              SizedBox(
                height: 10,
              ),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select a mood",
                ),
                value: _selectedMood,
                items: _moods.map((mood) {
                  return DropdownMenuItem(
                    value: mood,
                    child: Text(mood),
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
                controller: _customerMoodController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter a custom mood(optional)"),
              ),

              SizedBox(
                height: 20,
              ),

              TextField(
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
                              content: Text("No location found \"$value\"")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error finding location: $e ")),
                      );
                    }
                  });
                },
                decoration:
                    InputDecoration(hintText: "Enter location:(eg: New York)"),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
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
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Use GPS location"),
              ),

              _selectedLocation != null
                  ? Text("Selected Location: $_selectedLocation")
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
                  : Text("No images selected."),

              // _image!=null? Image.file(_image!,height: 200,width: 200,) :
              // Text("No image selected."),

              SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () => _getImage(ImageSource.gallery),
                child: Text("Select image"),
              ),

              SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed: () => _getImage(ImageSource.camera),
                child: Text("Click a photo"),
              ),

              SizedBox(
                height: 20,
              ),

              ElevatedButton(
                  onPressed: _saveJournal, child: Text("Save journal")),

              // ElevatedButton(
              //   onPressed: _showMapPicker,
              //   child: Text("Pick on Map"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
