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
