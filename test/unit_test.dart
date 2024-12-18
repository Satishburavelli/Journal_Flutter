import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  group('Journal JSON Tests', () {
    test('Saving journal to JSON file', () async {
      final file = File('journals.json');
      final sampleJournal = {
        'title': 'Sample Journal',
        'description': 'Test description',
        'mood': 'Happy',
        'location': 'Paris',
        'photos': []
      };

      await file.writeAsString(jsonEncode([sampleJournal]));
      final savedData = await file.readAsString();
      final savedJournals = jsonDecode(savedData);

      expect(savedJournals[0]['title'], equals('Sample Journal'));
    });
  });
}
