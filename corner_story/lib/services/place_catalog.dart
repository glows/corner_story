import 'dart:convert';

import 'package:flutter/services.dart';

/// The bundled, sourced catalogue also works when the API is unavailable.
class PlaceCatalog {
  static Future<List<Map<String, dynamic>>> loadNewYork() async {
    final data = jsonDecode(
      await rootBundle.loadString('assets/data/nyc_places.json'),
    ) as List;
    return data.cast<Map<String, dynamic>>();
  }
}
