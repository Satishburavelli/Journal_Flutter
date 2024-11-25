import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

class JournalEntry {
  final String title;
  final List<String> imagePaths;
  final String content;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? mood;
  final LatLng? location;

  JournalEntry({
    required this.title,
    required this.imagePaths,
    required this.content,
    this.latitude,
    this.longitude,
    this.locationName = '',
    this.mood = '',
    this.location,
  });

  // Convert coordinates to address
  static Future<String> getLocationName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.locality?.isNotEmpty ?? false) {
          address += place.locality!;
        }
        if (place.administrativeArea?.isNotEmpty ?? false) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        return address.isNotEmpty ? address : 'Unknown location';
      }
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Location unavailable';
    }
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'imagePaths': imagePaths,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'mood': mood,
        'location': location != null
            ? '${location!.latitude},${location!.longitude}'
            : null,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    List<String> imagePaths = [];
    if (json.containsKey('imagePaths')) {
      if (json['imagePaths'] is String) {
        imagePaths = List<String>.from(jsonDecode(json['imagePaths']));
      } else {
        imagePaths = List<String>.from(json['imagePaths']);
      }
    }

    LatLng? location;
    if (json['location'] != null && json['location'].isNotEmpty) {
      final coords = json['location'].split(',');
      if (coords.length == 2) {
        try {
          location = LatLng(
            double.parse(coords[0]),
            double.parse(coords[1]),
          );
        } catch (e) {
          print('Error parsing location: $e');
        }
      }
    }

    return JournalEntry(
      title: json['title'] ?? 'Untitled',
      content: json['content'] ?? 'No content',
      imagePaths: imagePaths,
      locationName: json['locationName'] ?? '',
      mood: json['mood'] ?? '',
      location: location,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  // Create a copy of JournalEntry with updated locationName
  JournalEntry copyWith({String? locationName}) {
    return JournalEntry(
      title: title,
      content: content,
      imagePaths: imagePaths,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName ?? this.locationName,
      mood: mood,
      location: location,
    );
  }
}
