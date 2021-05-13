import 'package:collection/collection.dart';
import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/model/db.dart';
import 'package:dbgen/topvars.dart';
import 'package:mysql1/mysql1.dart';

class MySqlOrMariaDBRepo {
  MySqlConnection? _conn;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  connect(ConnectionSettings settings) async {
    this._conn?.close(); // close exist connect.
    try {
      "test connecting server...".d();
      this._conn = await MySqlConnection.connect(settings);
      "server connected...".d();
      this._isConnected = true;
    } catch (e) {
      e.d();
      this._isConnected = false;
    }
  }

  Future<int> test(ConnectionSettings settings) async {
    try {
      final connect = await MySqlConnection.connect(settings);
      final Results results = await connect.query("SHOW DATABASES");
      return results.fields.length;
    } catch (e) {
      e.d();
      return -1;
    }
  }

  close() async {
    await this._conn?.close();
    this._conn = null;
    this._isConnected = false;
  }

  Future<Map<String, Iterable<Table>>> groupedTables() async {
    assert(this._conn != null, "MySqlConnection is not init.");
    final String sql = "SELECT "
        "TABLE_SCHEMA as db, "
        "TABLE_NAME as name, "
        "TABLE_TYPE as type, "
        "ENGINE as engine, "
        "CREATE_TIME as createAt, "
        "UPDATE_TIME as updateAt, "
        "TABLE_COLLATION as collation, "
        "TABLE_COMMENT as comment "
        "FROM information_schema.tables "
        "ORDER BY CREATE_TIME desc ";
    sql.d();
    final Results results = await this._conn!.query(sql);
    final Iterable<Table> tables = results.map(
      (e) {
        final db = e.fields["db"];
        final name = e.fields["name"];
        final id = "$db@$name";
        var color = tableColors[id];
        if (color == null) {
          color = LightColor.random();
          tableColors[id] = color;
        }
        if (!dbColors.containsKey(db)) {
          dbColors[db] = LightColor.random();
        }
        final engine = e.fields["engine"] as String?;
        if (!engine.isNullOrBlank && !tableTagsColors.containsKey(engine)) {
          tableTagsColors[engine!] = LightColor.random();
        }
        final collation = e.fields["collation"] as String?;
        if (!collation.isNullOrBlank &&
            !tableTagsColors.containsKey(collation)) {
          tableTagsColors[collation!] = LightColor.random();
        }
        final type = e.fields["type"] as String;
        if (!type.isNullOrBlank && !tableTagsColors.containsKey(type)) {
          tableTagsColors[type] = LightColor.random();
        }
        return Table(
          id,
          db,
          name,
          type,
          engine,
          e.fields["createAt"],
          e.fields["updateAt"],
          collation,
          e.fields["comment"].toString(),
          color,
        );
      },
    );
    return groupBy(tables, (it) => it.db);
    // var a = {};
    // List.generate(12, (index) {
    //   a["分组啊 $index"] = List.generate(
    //       64,
    //       (ind) => TableEntity(
    //           "$index.$ind",
    //           "",
    //           "$index.$ind 大家看红色的啊看",
    //           "dasdfa",
    //           "dasdas",
    //           DateTime.now(),
    //           DateTime.now(),
    //           "utf-8",
    //           "爱家卡圣诞节",
    //           LightColor.random()));
    // });
    // return a.cast();
  }

  Future<Iterable<Column>> columns(String db, String table) async {
    assert(this._conn != null, "MySqlConnection is not init.");
    final String sql = "SELECT "
        "TABLE_SCHEMA as db, "
        "TABLE_NAME as tb, "
        "COLUMN_NAME as name, "
        "ORDINAL_POSITION as sort, "
        "COLUMN_DEFAULT as defValue, "
        "IS_NULLABLE as nullable, "
        "DATA_TYPE as dataType, "
        "CHARACTER_SET_NAME as charset, "
        "COLUMN_TYPE as columnType, "
        "COLUMN_COMMENT as comment, "
        "EXTRA as extra, "
        "COLUMN_KEY as columnKey "
        "FROM information_schema.columns "
        "WHERE TABLE_SCHEMA = ? and TABLE_NAME = ? "
        "ORDER BY ordinal_position";
    sql.d();
    final Results results = await this._conn!.query(sql, [db, table]);
    return results.map(
      (e) {
        var db = e.fields['db'];
        var tb = e.fields['tb'];
        var name = e.fields['name'];
        return Column(
          "$db.$tb.$name",
          db,
          tb,
          name,
          e.fields['sort'],
          e.fields['defValue'],
          e.fields['nullable'],
          e.fields['dataType'],
          e.fields['charset'],
          e.fields['columnType'],
          e.fields['comment'],
          e.fields['extra'],
          e.fields['columnKey'],
        );
      },
    );
  }

  Future<String> ddl(String db, String table) async {
    assert(this._conn != null, "MySqlConnection is not init.");
    final Results results =
        await this._conn!.query("SHOW CREATE TABLE `$db`.`$table`");
    return results.last.fields.values.last;
  }
}
