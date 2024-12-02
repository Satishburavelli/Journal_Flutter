import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';

class JourneyMap extends StatefulWidget {
  const JourneyMap({super.key});

  @override
  State<JourneyMap> createState() => _JourneyMapState();
}

class _JourneyMapState extends State<JourneyMap> {
  List<LatLng> _locations = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (!await journalFile.exists()) return;

      final String fileContent = journalFile.readAsStringSync();
      final List<dynamic> journals = jsonDecode(fileContent);

      List<LatLng> loadedLocations = journals
          .map((entry) {
            if (entry['latitude'] != null && entry['longitude'] != null) {
              return LatLng(double.parse(entry['latitude'].toString()),
                  double.parse(entry['longitude'].toString()));
            }
            return null;
          })
          .where((loc) => loc != null)
          .cast<LatLng>()
          .toList();

      setState(() {
        _locations = loadedLocations;
      });
    } catch (e) {
      print("Error loadinggg: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          'My Journies',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _locations.isEmpty
          ? Center(
              child: Text(
                "No locations are here display",
                style: TextStyle(fontSize: 19,color: Colors.white70),
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _locations.isNotEmpty ? _locations.first : LatLng(0, 0),
                initialZoom: 5.0,
              )

              ,
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _locations.map((loc) {
                    return Marker(
                      point: loc,
                      width: 80.0,
                      height: 80.0,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 30.0,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
