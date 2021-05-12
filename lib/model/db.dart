import 'package:dbgen/isars.dart';
import 'package:flutter/rendering.dart';
import 'package:isar/isar.dart';
import 'package:mysql1/mysql1.dart';

@Collection()
class Connection {
  @Id()
  int? id;
  late String title;
  String? desc;
  late String host;
  late int port;
  String? user;
  String? password;
  bool useCompression = false;
  bool useSSL = false;
  int? maxPacketSize;
  int? charset;
  int? timeout;
  late DateTime createAt;
  DateTime? updateAt;
  DateTime? lastOpenAt;
  @ColorTypeConverter()
  late Color color;

  Connection();

  ConnectionSettings toSettings() {
    return ConnectionSettings(
      host: this.host,
      port: this.port,
      user: this.user,
      password: this.password,
      useCompression: this.useCompression,
      useSSL: this.useSSL,
      maxPacketSize: this.maxPacketSize ?? 16 * 1024 * 1024,
      characterSet: this.charset ?? CharacterSet.UTF8MB4,
      timeout: Duration(seconds: this.timeout ?? 30),
    );
  }

  void copyFrom(Connection connection) {
    this
      ..id = connection.id
      ..title = connection.title
      ..desc = connection.desc
      ..host = connection.host
      ..port = connection.port
      ..user = connection.user
      ..password = connection.password
      ..useCompression = connection.useCompression
      ..useSSL = connection.useSSL
      ..maxPacketSize = connection.maxPacketSize
      ..charset = connection.charset
      ..timeout = connection.timeout
      ..createAt = connection.createAt
      ..updateAt = connection.updateAt
      ..lastOpenAt = connection.lastOpenAt
      ..color = connection.color;
  }

  void emptyFields() {
    this
      ..id = null
      ..title = "未命名数据源"
      ..desc = null
      ..host = "localhost"
      ..port = 3306
      ..user = null
      ..password = null
      ..useCompression = false
      ..useSSL = false
      ..maxPacketSize = null
      ..charset = null
      ..timeout = null
      ..updateAt = null
      ..lastOpenAt = null;
  }

  void copySameFrom(Connection connection) {
    this
      ..id = null
      ..title = connection.title
      ..desc = connection.desc
      ..host = connection.host
      ..port = connection.port
      ..user = connection.user
      ..password = connection.password
      ..useCompression = connection.useCompression
      ..useSSL = connection.useSSL
      ..maxPacketSize = connection.maxPacketSize
      ..charset = connection.charset
      ..timeout = connection.timeout
      ..updateAt = null
      ..lastOpenAt = null;
  }
}

class Table {
  final String id;
  final String db;
  final String name;
  final String type;
  final String? engine;
  final DateTime createAt;
  final DateTime? updateAt;
  final String? collation;
  final String? comment;
  final Color color;

  const Table(
    this.id,
    this.db,
    this.name,
    this.type,
    this.engine,
    this.createAt,
    this.updateAt,
    this.collation,
    this.comment,
    this.color,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Table && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Column {
  final String id;
  final String db;
  final String tb;
  final String name;
  final int sort;
  final String? defValue;
  final String nullable;
  final String dataType;
  final String charset;
  final String columnType;
  final String comment;
  final String extra;
  final String columnKey;

  const Column(
    this.id,
    this.db,
    this.tb,
    this.name,
    this.sort,
    this.defValue,
    this.nullable,
    this.dataType,
    this.charset,
    this.columnType,
    this.comment,
    this.extra,
    this.columnKey,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Column && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
