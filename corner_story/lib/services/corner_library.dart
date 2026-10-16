import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Small device-local library for palate preferences and saved guides/places.
class CornerLibrary {
  static final instance = CornerLibrary();
  Future<void>? _writes;

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File('${directory.path}/corner_library.json');
  }

  Future<Map<String, dynamic>> read() async {
    final pending = _writes;
    if (pending != null) await pending;
    return _readFile();
  }

  Future<Map<String, dynamic>> _readFile() async {
    final file = await _file();
    if (!await file.exists()) return {};
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } on FormatException {
      return {};
    }
  }

  Future<void> put(String key, Object value) {
    final pending = _writes;
    final operation = () async {
      if (pending != null) await pending;
      final data = await _readFile();
      data[key] = value;
      final file = await _file();
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(jsonEncode(data), flush: true);
      await temporary.rename(file.path);
    }();
    _writes = operation;
    void clear() {
      if (identical(_writes, operation)) _writes = null;
    }

    operation.then<void>(
      (_) => clear(),
      onError: (Object _, StackTrace stack) => clear(),
    );
    return operation;
  }
}

/// Only these places have identities in the existing API's spot catalogue.
String? apiSpotIdForName(String name) => const {
  'Eavesdrop': 'spot_eavesdrop',
  'Public Records': 'spot_public_records',
  'SEY': 'spot_sey',
  'Radio Bakery — Prospect Heights': 'spot_radio_prospect',
  'Roman’s': 'spot_romans',
  'The Four Horsemen': 'spot_four_horsemen',
  'La Cabra — East Village': 'spot_la_cabra_east',
  'La Cabra — SoHo': 'spot_la_cabra_soho',
  'Housing Works Bookstore': 'spot_housing_works',
  'Paley Park': 'spot_paley_park',
  'Obvio': 'spot_obvio',
  'Obvio Cocktail Bar': 'spot_obvio',
  'Lei': 'spot_lei',
  'Céleste Gallery & Cafe': 'spot_celeste',
  'Radio Bakery': 'spot_radio',
  'Dimes Deli': 'spot_dimes',
  'Abraço': 'spot_abraco',
  'Abraço Espresso': 'spot_abraco',
  "Roman's": 'spot_romans',
  "Roman's Wine Cellar": 'spot_romans',
}[name];
