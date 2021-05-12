import 'package:dbgen/isars.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';

import '../isars.dart';

@Collection()
class Template {
  @Id()
  int? id;
  late String title;
  String? desc;
  late String lang;
  String? group;
  late String content;
  late String path;
  @StringMapTypeConverter()
  late Map<String, String> map;
  late DateTime createAt;
  DateTime? updateAt;

  Template();
}

@Collection()
class Lang {
  @Id()
  int? id;
  late String lang;
  String? desc;
  @StringMapTypeConverter()
  late Map<String, String> map;
  @ColorTypeConverter()
  late Color color;

  Lang();
}
