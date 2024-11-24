// import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_map/flutter_map.dart';
//
// import 'package:latlong2/latlong.dart';
//
// class JourneyMap extends StatefulWidget {
//   const JourneyMap({super.key});
//
//   @override
//   State<JourneyMap> createState() => _JourneyMapState();
// }
//
// class _JourneyMapState extends State<JourneyMap> {
//   List<LatLng> _locations = [];
//   final MapController _mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLocations();
//   }
//
//   Future<void> _loadLocations() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final journalFile = File('${directory.path}/journals.json');
//
//       if (!await journalFile.exists()) return;
//
//       final String fileContent = await journalFile.readAsStringSync();
//       final List<dynamic> journals = jsonDecode(fileContent);
//
//       List<LatLng> loadedLocations = journals
//           .map((entry) {
//             if (entry['location'] != null && entry['location']!.isNotEmpty) {
//               final coord = entry['location'].split(',');
//               return LatLng(double.parse(coord[0]), double.parse(coord[1]));
//             }
//             return null;
//           })
//           .where((loc) => loc != null)
//           .cast<LatLng>()
//           .toList();
//
//       // List<LatLng> loadedLocations = journals
//       //     .map((entry) {
//       //       if (entry['location'] != null && entry['location']!.isNotEmpty) {
//       //         final coord = entry['location'].split(',');
//       //         return LatLng(double.parse(coord[0]), double.parse(coord[1]));
//       //       }
//       //       return null;
//       //     })
//       //     .where((loc) => loc != null)
//       //     .cast<LatLng>()
//       //     .toList();
//
//       setState(() {
//         _locations = loadedLocations;
//       });
//     } catch (e) {
//       print("Error loading");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey[800],
//         title: const Text(
//           'My Journies',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: _locations.isEmpty
//           ? Center(
//               child: Text(
//                 "No journals are here display",
//                 style: TextStyle(fontSize: 19),
//               ),
//             )
//           : FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter:
//                     _locations.isNotEmpty ? _locations.first : LatLng(0, 0),
//                 initialZoom: 5.0,
//               )
//               // MapOptions(
//               //     center: _locations.isNotEmpty ? _locations.first : LatLng(0, 0),
//               //
//               //
//               //     zoom: 5.0,),
//               ,
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                 ),
//                 MarkerLayer(
//                   markers: _locations.map((loc) {
//                     return Marker(
//                       point: loc,
//                       width: 80.0,
//                       height: 80.0,
//                       child: const Icon(
//                         Icons.location_pin,
//                         color: Colors.red,
//                         size: 30.0,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        if (entry['location'] != null && entry['location']!.isNotEmpty) {
          final coord = entry['location'].split(',');
          return LatLng(double.parse(coord[0]), double.parse(coord[1]));
        }
        return null;
      })
          .where((loc) => loc != null)
          .cast<LatLng>()
          .toList();

      // List<LatLng> loadedLocations = journals
      //     .map((entry) {
      //       if (entry['location'] != null && entry['location']!.isNotEmpty) {
      //         final coord = entry['location'].split(',');
      //         return LatLng(double.parse(coord[0]), double.parse(coord[1]));
      //       }
      //       return null;
      //     })
      //     .where((loc) => loc != null)
      //     .cast<LatLng>()
      //     .toList();

      setState(() {
        _locations = loadedLocations;
      });
    } catch (e) {
      print("Error loading");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text(
          'My Journies',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _locations.isEmpty
          ? Center(
        child: Text(
          "No journals are here display",
          style: TextStyle(fontSize: 19),
        ),
      )
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter:
          _locations.isNotEmpty ? _locations.first : LatLng(0, 0),
          initialZoom: 5.0,
        )
        // MapOptions(
        //     center: _locations.isNotEmpty ? _locations.first : LatLng(0, 0),
        //
        //
        //     zoom: 5.0,),
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
