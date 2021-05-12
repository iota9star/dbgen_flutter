// ignore_for_file: unused_import, implementation_imports

import 'dart:ffi';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:isar/src/isar_native.dart';
import 'package:isar/src/query_builder.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'model/db.dart';
import 'model/template.dart';
import 'model/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:dbgen/isars.dart';

const _utf8Encoder = Utf8Encoder();

final _schema =
    '[{"name":"Connection","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"desc","type":5},{"name":"host","type":5},{"name":"port","type":3},{"name":"user","type":5},{"name":"password","type":5},{"name":"useCompression","type":0},{"name":"useSSL","type":0},{"name":"maxPacketSize","type":3},{"name":"charset","type":3},{"name":"timeout","type":3},{"name":"createAt","type":3},{"name":"updateAt","type":3},{"name":"lastOpenAt","type":3},{"name":"color","type":3}],"indexes":[],"links":[]},{"name":"Template","idProperty":"id","properties":[{"name":"id","type":3},{"name":"title","type":5},{"name":"desc","type":5},{"name":"lang","type":5},{"name":"group","type":5},{"name":"content","type":5},{"name":"path","type":5},{"name":"map","type":5},{"name":"createAt","type":3},{"name":"updateAt","type":3}],"indexes":[],"links":[]},{"name":"Lang","idProperty":"id","properties":[{"name":"id","type":3},{"name":"lang","type":5},{"name":"desc","type":5},{"name":"map","type":5},{"name":"color","type":3}],"indexes":[],"links":[]},{"name":"ITheme","idProperty":"id","properties":[{"name":"id","type":3},{"name":"activeAt","type":3},{"name":"canDelete","type":0},{"name":"autoMode","type":0},{"name":"isDark","type":0},{"name":"primaryColor","type":3},{"name":"accentColor","type":3},{"name":"lightBackgroundColor","type":3},{"name":"darkBackgroundColor","type":3},{"name":"lightScaffoldBackgroundColor","type":3},{"name":"darkScaffoldBackgroundColor","type":3}],"indexes":[],"links":[]}]';

Future<Isar> openIsar(
    {String name = 'isar',
    String? directory,
    int maxSize = 1000000000,
    Uint8List? encryptionKey}) async {
  final path = await _preparePath(directory);
  return openIsarInternal(
      name: name,
      directory: path,
      maxSize: maxSize,
      encryptionKey: encryptionKey,
      schema: _schema,
      getCollections: (isar) {
        final collectionPtrPtr = malloc<Pointer>();
        final propertyOffsetsPtr = malloc<Uint32>(16);
        final propertyOffsets = propertyOffsetsPtr.asTypedList(16);
        final collections = <String, IsarCollection>{};
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 0));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Connection'] = IsarCollectionImpl<Connection>(
          isar: isar,
          adapter: _ConnectionAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 16),
          propertyIds: {
            'id': 0,
            'title': 1,
            'desc': 2,
            'host': 3,
            'port': 4,
            'user': 5,
            'password': 6,
            'useCompression': 7,
            'useSSL': 8,
            'maxPacketSize': 9,
            'charset': 10,
            'timeout': 11,
            'createAt': 12,
            'updateAt': 13,
            'lastOpenAt': 14,
            'color': 15
          },
          indexIds: {},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 1));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Template'] = IsarCollectionImpl<Template>(
          isar: isar,
          adapter: _TemplateAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 10),
          propertyIds: {
            'id': 0,
            'title': 1,
            'desc': 2,
            'lang': 3,
            'group': 4,
            'content': 5,
            'path': 6,
            'map': 7,
            'createAt': 8,
            'updateAt': 9
          },
          indexIds: {},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 2));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['Lang'] = IsarCollectionImpl<Lang>(
          isar: isar,
          adapter: _LangAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 5),
          propertyIds: {'id': 0, 'lang': 1, 'desc': 2, 'map': 3, 'color': 4},
          indexIds: {},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        nCall(IC.isar_get_collection(isar.ptr, collectionPtrPtr, 3));
        IC.isar_get_property_offsets(
            collectionPtrPtr.value, propertyOffsetsPtr);
        collections['ITheme'] = IsarCollectionImpl<ITheme>(
          isar: isar,
          adapter: _IThemeAdapter(),
          ptr: collectionPtrPtr.value,
          propertyOffsets: propertyOffsets.sublist(0, 11),
          propertyIds: {
            'id': 0,
            'activeAt': 1,
            'canDelete': 2,
            'autoMode': 3,
            'isDark': 4,
            'primaryColor': 5,
            'accentColor': 6,
            'lightBackgroundColor': 7,
            'darkBackgroundColor': 8,
            'lightScaffoldBackgroundColor': 9,
            'darkScaffoldBackgroundColor': 10
          },
          indexIds: {},
          linkIds: {},
          backlinkIds: {},
          getId: (obj) => obj.id,
          setId: (obj, id) => obj.id = id,
        );
        malloc.free(propertyOffsetsPtr);
        malloc.free(collectionPtrPtr);

        return collections;
      });
}

Future<String> _preparePath(String? path) async {
  if (path == null || p.isRelative(path)) {
    WidgetsFlutterBinding.ensureInitialized();
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, path ?? 'isar');
  } else {
    return path;
  }
}

class _ConnectionAdapter extends TypeAdapter<Connection> {
  static const _ColorTypeConverter = ColorTypeConverter();

  @override
  int serialize(IsarCollectionImpl<Connection> collection, RawObject rawObj,
      Connection object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.title;
    final _title = _utf8Encoder.convert(value1);
    dynamicSize += _title.length;
    final value2 = object.desc;
    Uint8List? _desc;
    if (value2 != null) {
      _desc = _utf8Encoder.convert(value2);
    }
    dynamicSize += _desc?.length ?? 0;
    final value3 = object.host;
    final _host = _utf8Encoder.convert(value3);
    dynamicSize += _host.length;
    final value4 = object.port;
    final _port = value4;
    final value5 = object.user;
    Uint8List? _user;
    if (value5 != null) {
      _user = _utf8Encoder.convert(value5);
    }
    dynamicSize += _user?.length ?? 0;
    final value6 = object.password;
    Uint8List? _password;
    if (value6 != null) {
      _password = _utf8Encoder.convert(value6);
    }
    dynamicSize += _password?.length ?? 0;
    final value7 = object.useCompression;
    final _useCompression = value7;
    final value8 = object.useSSL;
    final _useSSL = value8;
    final value9 = object.maxPacketSize;
    final _maxPacketSize = value9;
    final value10 = object.charset;
    final _charset = value10;
    final value11 = object.timeout;
    final _timeout = value11;
    final value12 = object.createAt;
    final _createAt = value12;
    final value13 = object.updateAt;
    final _updateAt = value13;
    final value14 = object.lastOpenAt;
    final _lastOpenAt = value14;
    final value15 = _ConnectionAdapter._ColorTypeConverter.toIsar(object.color);
    final _color = value15;
    final size = dynamicSize + 116;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 116);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBytes(offsets[2], _desc);
    writer.writeBytes(offsets[3], _host);
    writer.writeLong(offsets[4], _port);
    writer.writeBytes(offsets[5], _user);
    writer.writeBytes(offsets[6], _password);
    writer.writeBool(offsets[7], _useCompression);
    writer.writeBool(offsets[8], _useSSL);
    writer.writeLong(offsets[9], _maxPacketSize);
    writer.writeLong(offsets[10], _charset);
    writer.writeLong(offsets[11], _timeout);
    writer.writeDateTime(offsets[12], _createAt);
    writer.writeDateTime(offsets[13], _updateAt);
    writer.writeDateTime(offsets[14], _lastOpenAt);
    writer.writeLong(offsets[15], _color);
    return bufferSize;
  }

  @override
  Connection deserialize(IsarCollectionImpl<Connection> collection,
      BinaryReader reader, List<int> offsets) {
    final object = Connection();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.desc = reader.readStringOrNull(offsets[2]);
    object.host = reader.readString(offsets[3]);
    object.port = reader.readLong(offsets[4]);
    object.user = reader.readStringOrNull(offsets[5]);
    object.password = reader.readStringOrNull(offsets[6]);
    object.useCompression = reader.readBool(offsets[7]);
    object.useSSL = reader.readBool(offsets[8]);
    object.maxPacketSize = reader.readLongOrNull(offsets[9]);
    object.charset = reader.readLongOrNull(offsets[10]);
    object.timeout = reader.readLongOrNull(offsets[11]);
    object.createAt = reader.readDateTime(offsets[12]);
    object.updateAt = reader.readDateTimeOrNull(offsets[13]);
    object.lastOpenAt = reader.readDateTimeOrNull(offsets[14]);
    object.color = _ConnectionAdapter._ColorTypeConverter.fromIsar(
        reader.readLong(offsets[15]));
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readStringOrNull(offset)) as P;
      case 3:
        return (reader.readString(offset)) as P;
      case 4:
        return (reader.readLong(offset)) as P;
      case 5:
        return (reader.readStringOrNull(offset)) as P;
      case 6:
        return (reader.readStringOrNull(offset)) as P;
      case 7:
        return (reader.readBool(offset)) as P;
      case 8:
        return (reader.readBool(offset)) as P;
      case 9:
        return (reader.readLongOrNull(offset)) as P;
      case 10:
        return (reader.readLongOrNull(offset)) as P;
      case 11:
        return (reader.readLongOrNull(offset)) as P;
      case 12:
        return (reader.readDateTime(offset)) as P;
      case 13:
        return (reader.readDateTimeOrNull(offset)) as P;
      case 14:
        return (reader.readDateTimeOrNull(offset)) as P;
      case 15:
        return (_ConnectionAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

class _TemplateAdapter extends TypeAdapter<Template> {
  static const _StringMapTypeConverter = StringMapTypeConverter();

  @override
  int serialize(IsarCollectionImpl<Template> collection, RawObject rawObj,
      Template object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.title;
    final _title = _utf8Encoder.convert(value1);
    dynamicSize += _title.length;
    final value2 = object.desc;
    Uint8List? _desc;
    if (value2 != null) {
      _desc = _utf8Encoder.convert(value2);
    }
    dynamicSize += _desc?.length ?? 0;
    final value3 = object.lang;
    final _lang = _utf8Encoder.convert(value3);
    dynamicSize += _lang.length;
    final value4 = object.group;
    Uint8List? _group;
    if (value4 != null) {
      _group = _utf8Encoder.convert(value4);
    }
    dynamicSize += _group?.length ?? 0;
    final value5 = object.content;
    final _content = _utf8Encoder.convert(value5);
    dynamicSize += _content.length;
    final value6 = object.path;
    final _path = _utf8Encoder.convert(value6);
    dynamicSize += _path.length;
    final value7 = _TemplateAdapter._StringMapTypeConverter.toIsar(object.map);
    final _map = _utf8Encoder.convert(value7);
    dynamicSize += _map.length;
    final value8 = object.createAt;
    final _createAt = value8;
    final value9 = object.updateAt;
    final _updateAt = value9;
    final size = dynamicSize + 82;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 82);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _title);
    writer.writeBytes(offsets[2], _desc);
    writer.writeBytes(offsets[3], _lang);
    writer.writeBytes(offsets[4], _group);
    writer.writeBytes(offsets[5], _content);
    writer.writeBytes(offsets[6], _path);
    writer.writeBytes(offsets[7], _map);
    writer.writeDateTime(offsets[8], _createAt);
    writer.writeDateTime(offsets[9], _updateAt);
    return bufferSize;
  }

  @override
  Template deserialize(IsarCollectionImpl<Template> collection,
      BinaryReader reader, List<int> offsets) {
    final object = Template();
    object.id = reader.readLongOrNull(offsets[0]);
    object.title = reader.readString(offsets[1]);
    object.desc = reader.readStringOrNull(offsets[2]);
    object.lang = reader.readString(offsets[3]);
    object.group = reader.readStringOrNull(offsets[4]);
    object.content = reader.readString(offsets[5]);
    object.path = reader.readString(offsets[6]);
    object.map = _TemplateAdapter._StringMapTypeConverter.fromIsar(
        reader.readString(offsets[7]));
    object.createAt = reader.readDateTime(offsets[8]);
    object.updateAt = reader.readDateTimeOrNull(offsets[9]);
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readStringOrNull(offset)) as P;
      case 3:
        return (reader.readString(offset)) as P;
      case 4:
        return (reader.readStringOrNull(offset)) as P;
      case 5:
        return (reader.readString(offset)) as P;
      case 6:
        return (reader.readString(offset)) as P;
      case 7:
        return (_TemplateAdapter._StringMapTypeConverter.fromIsar(
            reader.readString(offset))) as P;
      case 8:
        return (reader.readDateTime(offset)) as P;
      case 9:
        return (reader.readDateTimeOrNull(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

class _LangAdapter extends TypeAdapter<Lang> {
  static const _StringMapTypeConverter = StringMapTypeConverter();
  static const _ColorTypeConverter = ColorTypeConverter();

  @override
  int serialize(IsarCollectionImpl<Lang> collection, RawObject rawObj,
      Lang object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.lang;
    final _lang = _utf8Encoder.convert(value1);
    dynamicSize += _lang.length;
    final value2 = object.desc;
    Uint8List? _desc;
    if (value2 != null) {
      _desc = _utf8Encoder.convert(value2);
    }
    dynamicSize += _desc?.length ?? 0;
    final value3 = _LangAdapter._StringMapTypeConverter.toIsar(object.map);
    final _map = _utf8Encoder.convert(value3);
    dynamicSize += _map.length;
    final value4 = _LangAdapter._ColorTypeConverter.toIsar(object.color);
    final _color = value4;
    final size = dynamicSize + 42;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 42);
    writer.writeLong(offsets[0], _id);
    writer.writeBytes(offsets[1], _lang);
    writer.writeBytes(offsets[2], _desc);
    writer.writeBytes(offsets[3], _map);
    writer.writeLong(offsets[4], _color);
    return bufferSize;
  }

  @override
  Lang deserialize(IsarCollectionImpl<Lang> collection, BinaryReader reader,
      List<int> offsets) {
    final object = Lang();
    object.id = reader.readLongOrNull(offsets[0]);
    object.lang = reader.readString(offsets[1]);
    object.desc = reader.readStringOrNull(offsets[2]);
    object.map = _LangAdapter._StringMapTypeConverter.fromIsar(
        reader.readString(offsets[3]));
    object.color =
        _LangAdapter._ColorTypeConverter.fromIsar(reader.readLong(offsets[4]));
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readString(offset)) as P;
      case 2:
        return (reader.readStringOrNull(offset)) as P;
      case 3:
        return (_LangAdapter._StringMapTypeConverter.fromIsar(
            reader.readString(offset))) as P;
      case 4:
        return (_LangAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

class _IThemeAdapter extends TypeAdapter<ITheme> {
  static const _ColorTypeConverter = ColorTypeConverter();

  @override
  int serialize(IsarCollectionImpl<ITheme> collection, RawObject rawObj,
      ITheme object, List<int> offsets,
      [int? existingBufferSize]) {
    var dynamicSize = 0;
    final value0 = object.id;
    final _id = value0;
    final value1 = object.activeAt;
    final _activeAt = value1;
    final value2 = object.canDelete;
    final _canDelete = value2;
    final value3 = object.autoMode;
    final _autoMode = value3;
    final value4 = object.isDark;
    final _isDark = value4;
    final value5 =
        _IThemeAdapter._ColorTypeConverter.toIsar(object.primaryColor);
    final _primaryColor = value5;
    final value6 =
        _IThemeAdapter._ColorTypeConverter.toIsar(object.accentColor);
    final _accentColor = value6;
    final value7 =
        _IThemeAdapter._ColorTypeConverter.toIsar(object.lightBackgroundColor);
    final _lightBackgroundColor = value7;
    final value8 =
        _IThemeAdapter._ColorTypeConverter.toIsar(object.darkBackgroundColor);
    final _darkBackgroundColor = value8;
    final value9 = _IThemeAdapter._ColorTypeConverter.toIsar(
        object.lightScaffoldBackgroundColor);
    final _lightScaffoldBackgroundColor = value9;
    final value10 = _IThemeAdapter._ColorTypeConverter.toIsar(
        object.darkScaffoldBackgroundColor);
    final _darkScaffoldBackgroundColor = value10;
    final size = dynamicSize + 69;

    late int bufferSize;
    if (existingBufferSize != null) {
      if (existingBufferSize < size) {
        malloc.free(rawObj.buffer);
        rawObj.buffer = malloc(size);
        bufferSize = size;
      } else {
        bufferSize = existingBufferSize;
      }
    } else {
      rawObj.buffer = malloc(size);
      bufferSize = size;
    }
    rawObj.buffer_length = size;
    final buffer = rawObj.buffer.asTypedList(size);
    final writer = BinaryWriter(buffer, 69);
    writer.writeLong(offsets[0], _id);
    writer.writeLong(offsets[1], _activeAt);
    writer.writeBool(offsets[2], _canDelete);
    writer.writeBool(offsets[3], _autoMode);
    writer.writeBool(offsets[4], _isDark);
    writer.writeLong(offsets[5], _primaryColor);
    writer.writeLong(offsets[6], _accentColor);
    writer.writeLong(offsets[7], _lightBackgroundColor);
    writer.writeLong(offsets[8], _darkBackgroundColor);
    writer.writeLong(offsets[9], _lightScaffoldBackgroundColor);
    writer.writeLong(offsets[10], _darkScaffoldBackgroundColor);
    return bufferSize;
  }

  @override
  ITheme deserialize(IsarCollectionImpl<ITheme> collection, BinaryReader reader,
      List<int> offsets) {
    final object = ITheme();
    object.id = reader.readLongOrNull(offsets[0]);
    object.activeAt = reader.readLong(offsets[1]);
    object.canDelete = reader.readBool(offsets[2]);
    object.autoMode = reader.readBool(offsets[3]);
    object.isDark = reader.readBool(offsets[4]);
    object.primaryColor = _IThemeAdapter._ColorTypeConverter.fromIsar(
        reader.readLong(offsets[5]));
    object.accentColor = _IThemeAdapter._ColorTypeConverter.fromIsar(
        reader.readLong(offsets[6]));
    object.lightBackgroundColor = _IThemeAdapter._ColorTypeConverter.fromIsar(
        reader.readLong(offsets[7]));
    object.darkBackgroundColor = _IThemeAdapter._ColorTypeConverter.fromIsar(
        reader.readLong(offsets[8]));
    object.lightScaffoldBackgroundColor =
        _IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offsets[9]));
    object.darkScaffoldBackgroundColor =
        _IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offsets[10]));
    return object;
  }

  @override
  P deserializeProperty<P>(BinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case 0:
        return (reader.readLongOrNull(offset)) as P;
      case 1:
        return (reader.readLong(offset)) as P;
      case 2:
        return (reader.readBool(offset)) as P;
      case 3:
        return (reader.readBool(offset)) as P;
      case 4:
        return (reader.readBool(offset)) as P;
      case 5:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      case 6:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      case 7:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      case 8:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      case 9:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      case 10:
        return (_IThemeAdapter._ColorTypeConverter.fromIsar(
            reader.readLong(offset))) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }
}

extension GetCollection on Isar {
  IsarCollection<Connection> get connections {
    return getCollection('Connection');
  }

  IsarCollection<Template> get templates {
    return getCollection('Template');
  }

  IsarCollection<Lang> get langs {
    return getCollection('Lang');
  }

  IsarCollection<ITheme> get iThemes {
    return getCollection('ITheme');
  }
}

extension ConnectionQueryWhereSort on QueryBuilder<Connection, QWhere> {
  QueryBuilder<Connection, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension ConnectionQueryWhere on QueryBuilder<Connection, QWhereClause> {}

extension TemplateQueryWhereSort on QueryBuilder<Template, QWhere> {
  QueryBuilder<Template, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension TemplateQueryWhere on QueryBuilder<Template, QWhereClause> {}

extension LangQueryWhereSort on QueryBuilder<Lang, QWhere> {
  QueryBuilder<Lang, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension LangQueryWhere on QueryBuilder<Lang, QWhereClause> {}

extension IThemeQueryWhereSort on QueryBuilder<ITheme, QWhere> {
  QueryBuilder<ITheme, QAfterWhere> anyId() {
    return addWhereClause(WhereClause(indexName: 'id'));
  }
}

extension IThemeQueryWhere on QueryBuilder<ITheme, QWhereClause> {}

extension ConnectionQueryFilter on QueryBuilder<Connection, QFilterCondition> {
  QueryBuilder<Connection, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> idBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descStartsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descEndsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descContains(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> descMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> hostEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'host',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> hostStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'host',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> hostEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'host',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> hostContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'host',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> hostMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'host',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> portEqualTo(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'port',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> portGreaterThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'port',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> portLessThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'port',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> portBetween(
      int lower, int upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'port',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'user',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'user',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userStartsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'user',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userEndsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'user',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userContains(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'user',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> userMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'user',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'password',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'password',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordStartsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'password',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordEndsWith(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'password',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordContains(
      String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'password',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> passwordMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'password',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> useCompressionEqualTo(
      bool value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'useCompression',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> useSSLEqualTo(bool value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'useSSL',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> maxPacketSizeIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'maxPacketSize',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> maxPacketSizeEqualTo(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'maxPacketSize',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> maxPacketSizeGreaterThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'maxPacketSize',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> maxPacketSizeLessThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'maxPacketSize',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> maxPacketSizeBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'maxPacketSize',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> charsetIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'charset',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> charsetEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'charset',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> charsetGreaterThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'charset',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> charsetLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'charset',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> charsetBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'charset',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> timeoutIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'timeout',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> timeoutEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'timeout',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> timeoutGreaterThan(
      int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'timeout',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> timeoutLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'timeout',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> timeoutBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'timeout',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> createAtEqualTo(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> createAtGreaterThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> createAtLessThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> createAtBetween(
      DateTime lower, DateTime upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'createAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> updateAtIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'updateAt',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> updateAtEqualTo(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> updateAtGreaterThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> updateAtLessThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> updateAtBetween(
      DateTime? lower, DateTime? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'updateAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> lastOpenAtIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lastOpenAt',
      value: null,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> lastOpenAtEqualTo(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lastOpenAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> lastOpenAtGreaterThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'lastOpenAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> lastOpenAtLessThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'lastOpenAt',
      value: value,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> lastOpenAtBetween(
      DateTime? lower, DateTime? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'lastOpenAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> colorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'color',
      value: _ConnectionAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> colorGreaterThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'color',
      value: _ConnectionAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> colorLessThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'color',
      value: _ConnectionAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Connection, QAfterFilterCondition> colorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'color',
      lower: _ConnectionAdapter._ColorTypeConverter.toIsar(lower),
      upper: _ConnectionAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }
}

extension TemplateQueryFilter on QueryBuilder<Template, QFilterCondition> {
  QueryBuilder<Template, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> idBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> titleEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'title',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> titleStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> titleEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'title',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'title',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: null,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descStartsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descEndsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descContains(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> descMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> langEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lang',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> langStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'lang',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> langEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'lang',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> langContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lang',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> langMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lang',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'group',
      value: null,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'group',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupStartsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'group',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupEndsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'group',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupContains(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'group',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> groupMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'group',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> contentEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'content',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> contentStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'content',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> contentEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'content',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> contentContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'content',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> contentMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'content',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> pathEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'path',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> pathStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'path',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> pathEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'path',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> pathContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'path',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> pathMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'path',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> mapEqualTo(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'map',
      value: _TemplateAdapter._StringMapTypeConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> mapStartsWith(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue =
        _TemplateAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'map',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> mapEndsWith(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue =
        _TemplateAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'map',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> mapContains(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue =
        _TemplateAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'map',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> mapMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'map',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> createAtEqualTo(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> createAtGreaterThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> createAtLessThan(
      DateTime value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'createAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> createAtBetween(
      DateTime lower, DateTime upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'createAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> updateAtIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'updateAt',
      value: null,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> updateAtEqualTo(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> updateAtGreaterThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> updateAtLessThan(
      DateTime? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'updateAt',
      value: value,
    ));
  }

  QueryBuilder<Template, QAfterFilterCondition> updateAtBetween(
      DateTime? lower, DateTime? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'updateAt',
      lower: lower,
      upper: upper,
    ));
  }
}

extension LangQueryFilter on QueryBuilder<Lang, QFilterCondition> {
  QueryBuilder<Lang, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> idBetween(int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> langEqualTo(String value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lang',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> langStartsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'lang',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> langEndsWith(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'lang',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> langContains(String value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lang',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> langMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'lang',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: null,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descEqualTo(String? value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'desc',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descStartsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descEndsWith(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'desc',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descContains(String? value,
      {bool caseSensitive = true}) {
    final convertedValue = value;
    assert(convertedValue != null, 'Null values are not allowed');
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> descMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'desc',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> mapEqualTo(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'map',
      value: _LangAdapter._StringMapTypeConverter.toIsar(value),
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> mapStartsWith(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue = _LangAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.StartsWith,
      property: 'map',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> mapEndsWith(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue = _LangAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.EndsWith,
      property: 'map',
      value: convertedValue,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> mapContains(
      Map<String, String> value,
      {bool caseSensitive = true}) {
    final convertedValue = _LangAdapter._StringMapTypeConverter.toIsar(value);
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'map',
      value: '*$convertedValue*',
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> mapMatches(String pattern,
      {bool caseSensitive = true}) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Matches,
      property: 'map',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> colorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'color',
      value: _LangAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> colorGreaterThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'color',
      value: _LangAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> colorLessThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'color',
      value: _LangAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<Lang, QAfterFilterCondition> colorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'color',
      lower: _LangAdapter._ColorTypeConverter.toIsar(lower),
      upper: _LangAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }
}

extension IThemeQueryFilter on QueryBuilder<ITheme, QFilterCondition> {
  QueryBuilder<ITheme, QAfterFilterCondition> idIsNull() {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> idGreaterThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> idLessThan(int? value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> idBetween(
      int? lower, int? upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'id',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> activeAtEqualTo(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'activeAt',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> activeAtGreaterThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'activeAt',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> activeAtLessThan(int value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'activeAt',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> activeAtBetween(
      int lower, int upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'activeAt',
      lower: lower,
      upper: upper,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> canDeleteEqualTo(bool value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'canDelete',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> autoModeEqualTo(bool value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'autoMode',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> isDarkEqualTo(bool value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'isDark',
      value: value,
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> primaryColorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'primaryColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> primaryColorGreaterThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'primaryColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> primaryColorLessThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'primaryColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> primaryColorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'primaryColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> accentColorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'accentColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> accentColorGreaterThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'accentColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> accentColorLessThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'accentColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> accentColorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'accentColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> lightBackgroundColorEqualTo(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lightBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> lightBackgroundColorGreaterThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'lightBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> lightBackgroundColorLessThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'lightBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> lightBackgroundColorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'lightBackgroundColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> darkBackgroundColorEqualTo(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'darkBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> darkBackgroundColorGreaterThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'darkBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> darkBackgroundColorLessThan(
      Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'darkBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition> darkBackgroundColorBetween(
      Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'darkBackgroundColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      lightScaffoldBackgroundColorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'lightScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      lightScaffoldBackgroundColorGreaterThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'lightScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      lightScaffoldBackgroundColorLessThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'lightScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      lightScaffoldBackgroundColorBetween(Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'lightScaffoldBackgroundColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      darkScaffoldBackgroundColorEqualTo(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Eq,
      property: 'darkScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      darkScaffoldBackgroundColorGreaterThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Gt,
      property: 'darkScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      darkScaffoldBackgroundColorLessThan(Color value) {
    return addFilterCondition(FilterCondition(
      type: ConditionType.Lt,
      property: 'darkScaffoldBackgroundColor',
      value: _IThemeAdapter._ColorTypeConverter.toIsar(value),
    ));
  }

  QueryBuilder<ITheme, QAfterFilterCondition>
      darkScaffoldBackgroundColorBetween(Color lower, Color upper) {
    return addFilterCondition(FilterCondition.between(
      property: 'darkScaffoldBackgroundColor',
      lower: _IThemeAdapter._ColorTypeConverter.toIsar(lower),
      upper: _IThemeAdapter._ColorTypeConverter.toIsar(upper),
    ));
  }
}

extension ConnectionQueryLinks on QueryBuilder<Connection, QFilterCondition> {}

extension TemplateQueryLinks on QueryBuilder<Template, QFilterCondition> {}

extension LangQueryLinks on QueryBuilder<Lang, QFilterCondition> {}

extension IThemeQueryLinks on QueryBuilder<ITheme, QFilterCondition> {}

extension ConnectionQueryWhereSortBy on QueryBuilder<Connection, QSortBy> {
  QueryBuilder<Connection, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByHost() {
    return addSortByInternal('host', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByHostDesc() {
    return addSortByInternal('host', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByPort() {
    return addSortByInternal('port', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByPortDesc() {
    return addSortByInternal('port', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUser() {
    return addSortByInternal('user', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUserDesc() {
    return addSortByInternal('user', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByPassword() {
    return addSortByInternal('password', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByPasswordDesc() {
    return addSortByInternal('password', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUseCompression() {
    return addSortByInternal('useCompression', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUseCompressionDesc() {
    return addSortByInternal('useCompression', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUseSSL() {
    return addSortByInternal('useSSL', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUseSSLDesc() {
    return addSortByInternal('useSSL', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByMaxPacketSize() {
    return addSortByInternal('maxPacketSize', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByMaxPacketSizeDesc() {
    return addSortByInternal('maxPacketSize', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByCharset() {
    return addSortByInternal('charset', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByCharsetDesc() {
    return addSortByInternal('charset', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByTimeout() {
    return addSortByInternal('timeout', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByTimeoutDesc() {
    return addSortByInternal('timeout', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByCreateAt() {
    return addSortByInternal('createAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByCreateAtDesc() {
    return addSortByInternal('createAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUpdateAt() {
    return addSortByInternal('updateAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByUpdateAtDesc() {
    return addSortByInternal('updateAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByLastOpenAt() {
    return addSortByInternal('lastOpenAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByLastOpenAtDesc() {
    return addSortByInternal('lastOpenAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByColor() {
    return addSortByInternal('color', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> sortByColorDesc() {
    return addSortByInternal('color', Sort.Desc);
  }
}

extension ConnectionQueryWhereSortThenBy
    on QueryBuilder<Connection, QSortThenBy> {
  QueryBuilder<Connection, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByHost() {
    return addSortByInternal('host', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByHostDesc() {
    return addSortByInternal('host', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByPort() {
    return addSortByInternal('port', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByPortDesc() {
    return addSortByInternal('port', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUser() {
    return addSortByInternal('user', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUserDesc() {
    return addSortByInternal('user', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByPassword() {
    return addSortByInternal('password', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByPasswordDesc() {
    return addSortByInternal('password', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUseCompression() {
    return addSortByInternal('useCompression', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUseCompressionDesc() {
    return addSortByInternal('useCompression', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUseSSL() {
    return addSortByInternal('useSSL', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUseSSLDesc() {
    return addSortByInternal('useSSL', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByMaxPacketSize() {
    return addSortByInternal('maxPacketSize', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByMaxPacketSizeDesc() {
    return addSortByInternal('maxPacketSize', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByCharset() {
    return addSortByInternal('charset', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByCharsetDesc() {
    return addSortByInternal('charset', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByTimeout() {
    return addSortByInternal('timeout', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByTimeoutDesc() {
    return addSortByInternal('timeout', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByCreateAt() {
    return addSortByInternal('createAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByCreateAtDesc() {
    return addSortByInternal('createAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUpdateAt() {
    return addSortByInternal('updateAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByUpdateAtDesc() {
    return addSortByInternal('updateAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByLastOpenAt() {
    return addSortByInternal('lastOpenAt', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByLastOpenAtDesc() {
    return addSortByInternal('lastOpenAt', Sort.Desc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByColor() {
    return addSortByInternal('color', Sort.Asc);
  }

  QueryBuilder<Connection, QAfterSortBy> thenByColorDesc() {
    return addSortByInternal('color', Sort.Desc);
  }
}

extension TemplateQueryWhereSortBy on QueryBuilder<Template, QSortBy> {
  QueryBuilder<Template, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByLang() {
    return addSortByInternal('lang', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByLangDesc() {
    return addSortByInternal('lang', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByGroup() {
    return addSortByInternal('group', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByGroupDesc() {
    return addSortByInternal('group', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByContent() {
    return addSortByInternal('content', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByContentDesc() {
    return addSortByInternal('content', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByPath() {
    return addSortByInternal('path', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByPathDesc() {
    return addSortByInternal('path', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByMap() {
    return addSortByInternal('map', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByMapDesc() {
    return addSortByInternal('map', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByCreateAt() {
    return addSortByInternal('createAt', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByCreateAtDesc() {
    return addSortByInternal('createAt', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByUpdateAt() {
    return addSortByInternal('updateAt', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> sortByUpdateAtDesc() {
    return addSortByInternal('updateAt', Sort.Desc);
  }
}

extension TemplateQueryWhereSortThenBy on QueryBuilder<Template, QSortThenBy> {
  QueryBuilder<Template, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByTitle() {
    return addSortByInternal('title', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByTitleDesc() {
    return addSortByInternal('title', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByLang() {
    return addSortByInternal('lang', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByLangDesc() {
    return addSortByInternal('lang', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByGroup() {
    return addSortByInternal('group', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByGroupDesc() {
    return addSortByInternal('group', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByContent() {
    return addSortByInternal('content', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByContentDesc() {
    return addSortByInternal('content', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByPath() {
    return addSortByInternal('path', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByPathDesc() {
    return addSortByInternal('path', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByMap() {
    return addSortByInternal('map', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByMapDesc() {
    return addSortByInternal('map', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByCreateAt() {
    return addSortByInternal('createAt', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByCreateAtDesc() {
    return addSortByInternal('createAt', Sort.Desc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByUpdateAt() {
    return addSortByInternal('updateAt', Sort.Asc);
  }

  QueryBuilder<Template, QAfterSortBy> thenByUpdateAtDesc() {
    return addSortByInternal('updateAt', Sort.Desc);
  }
}

extension LangQueryWhereSortBy on QueryBuilder<Lang, QSortBy> {
  QueryBuilder<Lang, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByLang() {
    return addSortByInternal('lang', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByLangDesc() {
    return addSortByInternal('lang', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByMap() {
    return addSortByInternal('map', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByMapDesc() {
    return addSortByInternal('map', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByColor() {
    return addSortByInternal('color', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> sortByColorDesc() {
    return addSortByInternal('color', Sort.Desc);
  }
}

extension LangQueryWhereSortThenBy on QueryBuilder<Lang, QSortThenBy> {
  QueryBuilder<Lang, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByLang() {
    return addSortByInternal('lang', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByLangDesc() {
    return addSortByInternal('lang', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByDesc() {
    return addSortByInternal('desc', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByDescDesc() {
    return addSortByInternal('desc', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByMap() {
    return addSortByInternal('map', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByMapDesc() {
    return addSortByInternal('map', Sort.Desc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByColor() {
    return addSortByInternal('color', Sort.Asc);
  }

  QueryBuilder<Lang, QAfterSortBy> thenByColorDesc() {
    return addSortByInternal('color', Sort.Desc);
  }
}

extension IThemeQueryWhereSortBy on QueryBuilder<ITheme, QSortBy> {
  QueryBuilder<ITheme, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByActiveAt() {
    return addSortByInternal('activeAt', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByActiveAtDesc() {
    return addSortByInternal('activeAt', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByCanDelete() {
    return addSortByInternal('canDelete', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByCanDeleteDesc() {
    return addSortByInternal('canDelete', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByAutoMode() {
    return addSortByInternal('autoMode', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByAutoModeDesc() {
    return addSortByInternal('autoMode', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByIsDark() {
    return addSortByInternal('isDark', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByIsDarkDesc() {
    return addSortByInternal('isDark', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByPrimaryColor() {
    return addSortByInternal('primaryColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByPrimaryColorDesc() {
    return addSortByInternal('primaryColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByAccentColor() {
    return addSortByInternal('accentColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByAccentColorDesc() {
    return addSortByInternal('accentColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByLightBackgroundColor() {
    return addSortByInternal('lightBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByLightBackgroundColorDesc() {
    return addSortByInternal('lightBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByDarkBackgroundColor() {
    return addSortByInternal('darkBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByDarkBackgroundColorDesc() {
    return addSortByInternal('darkBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByLightScaffoldBackgroundColor() {
    return addSortByInternal('lightScaffoldBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByLightScaffoldBackgroundColorDesc() {
    return addSortByInternal('lightScaffoldBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByDarkScaffoldBackgroundColor() {
    return addSortByInternal('darkScaffoldBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> sortByDarkScaffoldBackgroundColorDesc() {
    return addSortByInternal('darkScaffoldBackgroundColor', Sort.Desc);
  }
}

extension IThemeQueryWhereSortThenBy on QueryBuilder<ITheme, QSortThenBy> {
  QueryBuilder<ITheme, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByActiveAt() {
    return addSortByInternal('activeAt', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByActiveAtDesc() {
    return addSortByInternal('activeAt', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByCanDelete() {
    return addSortByInternal('canDelete', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByCanDeleteDesc() {
    return addSortByInternal('canDelete', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByAutoMode() {
    return addSortByInternal('autoMode', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByAutoModeDesc() {
    return addSortByInternal('autoMode', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByIsDark() {
    return addSortByInternal('isDark', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByIsDarkDesc() {
    return addSortByInternal('isDark', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByPrimaryColor() {
    return addSortByInternal('primaryColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByPrimaryColorDesc() {
    return addSortByInternal('primaryColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByAccentColor() {
    return addSortByInternal('accentColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByAccentColorDesc() {
    return addSortByInternal('accentColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByLightBackgroundColor() {
    return addSortByInternal('lightBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByLightBackgroundColorDesc() {
    return addSortByInternal('lightBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByDarkBackgroundColor() {
    return addSortByInternal('darkBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByDarkBackgroundColorDesc() {
    return addSortByInternal('darkBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByLightScaffoldBackgroundColor() {
    return addSortByInternal('lightScaffoldBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByLightScaffoldBackgroundColorDesc() {
    return addSortByInternal('lightScaffoldBackgroundColor', Sort.Desc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByDarkScaffoldBackgroundColor() {
    return addSortByInternal('darkScaffoldBackgroundColor', Sort.Asc);
  }

  QueryBuilder<ITheme, QAfterSortBy> thenByDarkScaffoldBackgroundColorDesc() {
    return addSortByInternal('darkScaffoldBackgroundColor', Sort.Desc);
  }
}

extension ConnectionQueryWhereDistinct on QueryBuilder<Connection, QDistinct> {
  QueryBuilder<Connection, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Connection, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('title', caseSensitive: caseSensitive);
  }

  QueryBuilder<Connection, QDistinct> distinctByDesc(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('desc', caseSensitive: caseSensitive);
  }

  QueryBuilder<Connection, QDistinct> distinctByHost(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('host', caseSensitive: caseSensitive);
  }

  QueryBuilder<Connection, QDistinct> distinctByPort() {
    return addDistinctByInternal('port');
  }

  QueryBuilder<Connection, QDistinct> distinctByUser(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('user', caseSensitive: caseSensitive);
  }

  QueryBuilder<Connection, QDistinct> distinctByPassword(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('password', caseSensitive: caseSensitive);
  }

  QueryBuilder<Connection, QDistinct> distinctByUseCompression() {
    return addDistinctByInternal('useCompression');
  }

  QueryBuilder<Connection, QDistinct> distinctByUseSSL() {
    return addDistinctByInternal('useSSL');
  }

  QueryBuilder<Connection, QDistinct> distinctByMaxPacketSize() {
    return addDistinctByInternal('maxPacketSize');
  }

  QueryBuilder<Connection, QDistinct> distinctByCharset() {
    return addDistinctByInternal('charset');
  }

  QueryBuilder<Connection, QDistinct> distinctByTimeout() {
    return addDistinctByInternal('timeout');
  }

  QueryBuilder<Connection, QDistinct> distinctByCreateAt() {
    return addDistinctByInternal('createAt');
  }

  QueryBuilder<Connection, QDistinct> distinctByUpdateAt() {
    return addDistinctByInternal('updateAt');
  }

  QueryBuilder<Connection, QDistinct> distinctByLastOpenAt() {
    return addDistinctByInternal('lastOpenAt');
  }

  QueryBuilder<Connection, QDistinct> distinctByColor() {
    return addDistinctByInternal('color');
  }
}

extension TemplateQueryWhereDistinct on QueryBuilder<Template, QDistinct> {
  QueryBuilder<Template, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Template, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('title', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByDesc(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('desc', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByLang(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('lang', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByGroup(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('group', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('content', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByPath(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('path', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByMap({bool caseSensitive = true}) {
    return addDistinctByInternal('map', caseSensitive: caseSensitive);
  }

  QueryBuilder<Template, QDistinct> distinctByCreateAt() {
    return addDistinctByInternal('createAt');
  }

  QueryBuilder<Template, QDistinct> distinctByUpdateAt() {
    return addDistinctByInternal('updateAt');
  }
}

extension LangQueryWhereDistinct on QueryBuilder<Lang, QDistinct> {
  QueryBuilder<Lang, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Lang, QDistinct> distinctByLang({bool caseSensitive = true}) {
    return addDistinctByInternal('lang', caseSensitive: caseSensitive);
  }

  QueryBuilder<Lang, QDistinct> distinctByDesc({bool caseSensitive = true}) {
    return addDistinctByInternal('desc', caseSensitive: caseSensitive);
  }

  QueryBuilder<Lang, QDistinct> distinctByMap({bool caseSensitive = true}) {
    return addDistinctByInternal('map', caseSensitive: caseSensitive);
  }

  QueryBuilder<Lang, QDistinct> distinctByColor() {
    return addDistinctByInternal('color');
  }
}

extension IThemeQueryWhereDistinct on QueryBuilder<ITheme, QDistinct> {
  QueryBuilder<ITheme, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<ITheme, QDistinct> distinctByActiveAt() {
    return addDistinctByInternal('activeAt');
  }

  QueryBuilder<ITheme, QDistinct> distinctByCanDelete() {
    return addDistinctByInternal('canDelete');
  }

  QueryBuilder<ITheme, QDistinct> distinctByAutoMode() {
    return addDistinctByInternal('autoMode');
  }

  QueryBuilder<ITheme, QDistinct> distinctByIsDark() {
    return addDistinctByInternal('isDark');
  }

  QueryBuilder<ITheme, QDistinct> distinctByPrimaryColor() {
    return addDistinctByInternal('primaryColor');
  }

  QueryBuilder<ITheme, QDistinct> distinctByAccentColor() {
    return addDistinctByInternal('accentColor');
  }

  QueryBuilder<ITheme, QDistinct> distinctByLightBackgroundColor() {
    return addDistinctByInternal('lightBackgroundColor');
  }

  QueryBuilder<ITheme, QDistinct> distinctByDarkBackgroundColor() {
    return addDistinctByInternal('darkBackgroundColor');
  }

  QueryBuilder<ITheme, QDistinct> distinctByLightScaffoldBackgroundColor() {
    return addDistinctByInternal('lightScaffoldBackgroundColor');
  }

  QueryBuilder<ITheme, QDistinct> distinctByDarkScaffoldBackgroundColor() {
    return addDistinctByInternal('darkScaffoldBackgroundColor');
  }
}

extension ConnectionQueryProperty on QueryBuilder<Connection, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> titleProperty() {
    return addPropertyName('title');
  }

  QueryBuilder<String?, QQueryOperations> descProperty() {
    return addPropertyName('desc');
  }

  QueryBuilder<String, QQueryOperations> hostProperty() {
    return addPropertyName('host');
  }

  QueryBuilder<int, QQueryOperations> portProperty() {
    return addPropertyName('port');
  }

  QueryBuilder<String?, QQueryOperations> userProperty() {
    return addPropertyName('user');
  }

  QueryBuilder<String?, QQueryOperations> passwordProperty() {
    return addPropertyName('password');
  }

  QueryBuilder<bool, QQueryOperations> useCompressionProperty() {
    return addPropertyName('useCompression');
  }

  QueryBuilder<bool, QQueryOperations> useSSLProperty() {
    return addPropertyName('useSSL');
  }

  QueryBuilder<int?, QQueryOperations> maxPacketSizeProperty() {
    return addPropertyName('maxPacketSize');
  }

  QueryBuilder<int?, QQueryOperations> charsetProperty() {
    return addPropertyName('charset');
  }

  QueryBuilder<int?, QQueryOperations> timeoutProperty() {
    return addPropertyName('timeout');
  }

  QueryBuilder<DateTime, QQueryOperations> createAtProperty() {
    return addPropertyName('createAt');
  }

  QueryBuilder<DateTime?, QQueryOperations> updateAtProperty() {
    return addPropertyName('updateAt');
  }

  QueryBuilder<DateTime?, QQueryOperations> lastOpenAtProperty() {
    return addPropertyName('lastOpenAt');
  }

  QueryBuilder<Color, QQueryOperations> colorProperty() {
    return addPropertyName('color');
  }
}

extension TemplateQueryProperty on QueryBuilder<Template, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> titleProperty() {
    return addPropertyName('title');
  }

  QueryBuilder<String?, QQueryOperations> descProperty() {
    return addPropertyName('desc');
  }

  QueryBuilder<String, QQueryOperations> langProperty() {
    return addPropertyName('lang');
  }

  QueryBuilder<String?, QQueryOperations> groupProperty() {
    return addPropertyName('group');
  }

  QueryBuilder<String, QQueryOperations> contentProperty() {
    return addPropertyName('content');
  }

  QueryBuilder<String, QQueryOperations> pathProperty() {
    return addPropertyName('path');
  }

  QueryBuilder<Map<String, String>, QQueryOperations> mapProperty() {
    return addPropertyName('map');
  }

  QueryBuilder<DateTime, QQueryOperations> createAtProperty() {
    return addPropertyName('createAt');
  }

  QueryBuilder<DateTime?, QQueryOperations> updateAtProperty() {
    return addPropertyName('updateAt');
  }
}

extension LangQueryProperty on QueryBuilder<Lang, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<String, QQueryOperations> langProperty() {
    return addPropertyName('lang');
  }

  QueryBuilder<String?, QQueryOperations> descProperty() {
    return addPropertyName('desc');
  }

  QueryBuilder<Map<String, String>, QQueryOperations> mapProperty() {
    return addPropertyName('map');
  }

  QueryBuilder<Color, QQueryOperations> colorProperty() {
    return addPropertyName('color');
  }
}

extension IThemeQueryProperty on QueryBuilder<ITheme, QQueryProperty> {
  QueryBuilder<int?, QQueryOperations> idProperty() {
    return addPropertyName('id');
  }

  QueryBuilder<int, QQueryOperations> activeAtProperty() {
    return addPropertyName('activeAt');
  }

  QueryBuilder<bool, QQueryOperations> canDeleteProperty() {
    return addPropertyName('canDelete');
  }

  QueryBuilder<bool, QQueryOperations> autoModeProperty() {
    return addPropertyName('autoMode');
  }

  QueryBuilder<bool, QQueryOperations> isDarkProperty() {
    return addPropertyName('isDark');
  }

  QueryBuilder<Color, QQueryOperations> primaryColorProperty() {
    return addPropertyName('primaryColor');
  }

  QueryBuilder<Color, QQueryOperations> accentColorProperty() {
    return addPropertyName('accentColor');
  }

  QueryBuilder<Color, QQueryOperations> lightBackgroundColorProperty() {
    return addPropertyName('lightBackgroundColor');
  }

  QueryBuilder<Color, QQueryOperations> darkBackgroundColorProperty() {
    return addPropertyName('darkBackgroundColor');
  }

  QueryBuilder<Color, QQueryOperations> lightScaffoldBackgroundColorProperty() {
    return addPropertyName('lightScaffoldBackgroundColor');
  }

  QueryBuilder<Color, QQueryOperations> darkScaffoldBackgroundColorProperty() {
    return addPropertyName('darkScaffoldBackgroundColor');
  }
}
