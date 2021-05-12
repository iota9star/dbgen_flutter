import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:isar/isar.dart';

class ColorTypeConverter extends TypeConverter<Color, int> {
  @override
  Color fromIsar(int object) {
    return Color(object);
  }

  @override
  int toIsar(Color object) {
    return object.value;
  }

  const ColorTypeConverter();
}

class StringMapTypeConverter
    extends TypeConverter<Map<String, String>, String> {
  @override
  Map<String, String> fromIsar(String object) {
    return jsonDecode(object);
  }

  @override
  String toIsar(Map<String, String> object) {
    return jsonEncode(object);
  }

  const StringMapTypeConverter();
}
