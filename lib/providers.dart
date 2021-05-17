import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isar.g.dart';
import 'package:dbgen/model/db.dart';
import 'package:dbgen/model/theme.dart';
import 'package:dbgen/repo/db_repo.dart';
import 'package:dbgen/topvars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';

import 'model/db.dart';
import 'topvars.dart';

class RiverpodLogger extends ProviderObserver {
  const RiverpodLogger();

  @override
  void didUpdateProvider(ProviderBase provider, Object? newValue) {
    "${provider.name ?? provider.runtimeType} did update.".d();
  }
//
// @override
// void didDisposeProvider(ProviderBase provider) {
//   "${provider.name ?? provider.runtimeType} did dispose.".d();
// }
//
// @override
// void mayHaveChanged(ProviderBase provider) {
//   "${provider.name ?? provider.runtimeType} may have changed.".d();
// }
//
// @override
// void didAddProvider(ProviderBase provider, Object? value) {
//   "${provider.name ?? provider.runtimeType} did add.".d();
// }
}

final _dbRepoProvider = Provider<MySqlOrMariaDBRepo>((ref) {
  return MySqlOrMariaDBRepo();
});

final selectedConnectNotifierProvider =
    StateNotifierProvider<SelectedConnectionNotifier, Connection>(
        (ref) => SelectedConnectionNotifier());

class SelectedConnectionNotifier extends StateNotifier<Connection> {
  SelectedConnectionNotifier() : super(Connection());

  copyFrom(Connection connection) {
    this.state.copyFrom(connection);
  }

  emptyFields() {
    this.state.emptyFields();
  }
}

final dbRepoProvider =
    FutureProvider.autoDispose<MySqlOrMariaDBRepo>((ref) async {
  final connection = ref.watch(selectedConnectNotifierProvider);
  final repo = ref.read(_dbRepoProvider);
  final isar = ref.read(isarProvider);
  connection.lastOpenAt = DateTime.now();
  await isar.writeTxn((isar) async {
    await isar.connections.put(connection);
  });
  ref.onDispose(repo.close);
  await repo.connect(connection);
  return repo;
});

final groupedTablesProvider =
    FutureProvider.autoDispose<Map<String, Iterable<Table>>>((ref) async {
  final repo = await ref.watch(dbRepoProvider.future);
  ref.read(tableSearchProvider.notifier).state = "";
  ref.read(dbFilterProvider.notifier).clear();
  return await repo.groupedTables();
});

final dbTablesProvider =
    FutureProvider.autoDispose<Map<String, Iterable<Table>>>((ref) async {
  final showSys = ref.watch(showSysDBProvider).state;
  final groupTables = await ref.watch(groupedTablesProvider.future);
  final states = <String, int>{};
  final noSys = <String, Iterable<Table>>{};
  groupTables.forEach((key, value) {
    states[key] = value.length;
    if (!sysDB.contains(key.toLowerCase())) {
      noSys[key] = value;
    }
  });
  ref.read(dbTableCountStateProvider.notifier).state = states;
  if (!showSys) {
    return noSys;
  }
  return groupTables;
});
final dbTableCountStateProvider = StateProvider<Map<String, int>>((ref) => {});

final dbCheckStateProvider =
    StateNotifierProvider<DBCheckStateNotifier, Map<String, bool?>>((ref) {
  final countState = ref.read(dbTableCountStateProvider).state;
  final selected = ref.watch(selectedTableProvider);
  final values = selected.values;
  final selectedGrouped = groupBy(values, (Table it) => it.db);
  final map = <String, bool?>{};
  countState.forEach((key, length) {
    final selectedLen = selectedGrouped[key]?.length ?? -1;
    if (selectedLen == length) {
      map[key] = true;
    } else if (selectedLen > 0) {
      map[key] = null;
    } else {
      map[key] = false;
    }
  });
  return DBCheckStateNotifier(map);
});

class DBCheckStateNotifier extends StateNotifier<Map<String, bool?>> {
  DBCheckStateNotifier(Map<String, bool?> state) : super(state);

  operator []=(String key, bool? value) {
    this.state[key] = value;
    notifyListeners();
  }
}

final filteredGroupedTablesProvider =
    FutureProvider.autoDispose<Map<String, Iterable<Table>>>((ref) async {
  final filters = ref.watch(dbFilterProvider);
  final keywords = ref.watch(tableSearchProvider).state;
  final grouped = ref.watch(dbTablesProvider);
  return grouped.when(
      data: (data) {
        final isBlankKeywords = keywords.isNullOrBlank;
        var isEmptyFilter = filters.isEmpty;
        if (isEmptyFilter && isBlankKeywords) {
          return data;
        }
        final filtered = {};
        if (isEmptyFilter) {
          data.forEach((key, list) {
            final searched = list.where((tb) => tb.name.contains(keywords));
            if (!searched.isNullOrEmpty) {
              filtered[key] = searched;
            }
          });
        } else if (isBlankKeywords) {
          for (final String db in filters) {
            filtered[db] = data[db];
          }
        } else {
          for (final String db in filters) {
            final searched =
                data[db]?.where((tb) => tb.name.contains(keywords));
            if (!searched.isNullOrEmpty) {
              filtered[db] = searched;
            }
          }
        }
        return filtered.cast();
      },
      loading: () => emptyMap.cast(),
      error: (_, __) => emptyMap.cast());
});

final tableItemProvider = ScopedProvider<Table>(null);
final tableItemIsSelectedProvider = ScopedProvider<bool>(null);

final filteredTableProvider =
    FutureProvider.autoDispose<Tuple4<int, int, int, int>>((ref) async {
  final full = await ref.watch(dbTablesProvider.future);
  final filtered = ref.watch(filteredGroupedTablesProvider);
  if (full.isEmpty) {
    return Tuple4(0, 0, 0, 0);
  }
  return filtered.when(
      data: (data) {
        final entries1 = full.entries;
        var count1 = 0;
        for (var entry in entries1) {
          count1 += entry.value.length;
        }
        final entries2 = data.entries;
        var count2 = 0;
        for (var entry in entries2) {
          count2 += entry.value.length;
        }
        return Tuple4(entries1.length, count1, entries2.length, count2);
      },
      loading: () => Tuple4(0, 0, 0, 0),
      error: (_, __) => Tuple4(0, 0, 0, 0));
});

final tableSearchProvider = StateProvider((ref) => "");

final showSysDBProvider = StateProvider((ref) => false);

final dbFilterProvider = StateNotifierProvider<DBFilterNotifier, Set<String>>(
    (ref) => DBFilterNotifier());
final dbKeyProvider = ScopedProvider<String>(null);
final dbSectionKeyProvider = ScopedProvider<String>(null);

class DBFilterNotifier extends StateNotifier<Set<String>> {
  DBFilterNotifier() : super({});

  void add(String value) {
    this.state.add(value);
    notifyListeners();
  }

  void remove(String value) {
    this.state.remove(value);
    notifyListeners();
  }

  void clear() {
    this.state.clear();
    notifyListeners();
  }

  void toggle(String value) {
    if (this.state.contains(value)) {
      this.state.remove(value);
    } else {
      this.state.add(value);
    }
    notifyListeners();
  }
}

final selectedTableProvider =
    StateNotifierProvider<SelectedTableNotifier, Map<String, Table>>(
        (ref) => SelectedTableNotifier(ref.read));

class SelectedTableNotifier extends StateNotifier<Map<String, Table>> {
  SelectedTableNotifier(this.read) : super({});
  final Reader read;

  operator []=(String key, Table value) {
    this.state[key] = value;
    refresh();
  }

  void remove(String key) {
    this.state.remove(key);
    refresh();
  }

  void refresh() {
    this.state = this.state;
    read(tableCartFloatCountNotifierProvider.notifier).set(state.length);
  }

  void uncheck(String db) {
    this.state.removeWhere((key, value) => value.db == db);
    refresh();
  }

  void check(String db) async {
    final groupedTables = await read(dbTablesProvider.future);
    groupedTables[db]?.forEach((tb) {
      this.state[tb.id] = tb;
    });
    refresh();
  }
}

final navRailExtendedProvider = StateProvider<bool>((ref) => true);
final navRailSelectedProvider =
    StateProvider<DestinationItem>((ref) => destinationItems.first);

final windowButtonHoverIndexProvider = StateProvider<int>((ref) => -1);
final windowButtonIndexProvider = ScopedProvider<int>(null);

final connectionItemProvider = ScopedProvider<Connection?>((ref) => null);

final rootIsarProvider = Provider<Isar?>((ref) => null);
final isarProvider = Provider<Isar>((ref) {
  return ref.watch(rootIsarProvider)!;
});

final themesProvider = FutureProvider<List<ITheme>>((ref) async {
  final isar = ref.read(isarProvider);
  final all = await isar.iThemes.where().findAll();
  if (all.isEmpty) {
    return [defaultTheme];
  }
  return all;
});

final selectedThemeProvider = FutureProvider<ITheme>((ref) async {
  final isar = ref.read(isarProvider);
  final id = await ref.watch(selectedThemeIdProvider.future);
  if (id == null) {
    final count = await isar.iThemes.where().count();
    if (count == 0) {
      await isar.writeTxn((isar) async {
        await isar.iThemes.put(defaultTheme);
      });
      return defaultTheme;
    } else {
      final active =
          await isar.iThemes.where().sortByActiveAtDesc().findFirst();
      if (active == null) {
        final first = (await isar.iThemes.where().findFirst())!;
        first.activeAt = DateTime.now().millisecondsSinceEpoch;
        await isar.iThemes.put(first);
        return first;
      }
      return active;
    }
  } else {
    final selected = (await isar.iThemes.get(id)) ?? defaultTheme;
    selected.activeAt = DateTime.now().millisecondsSinceEpoch;
    await isar.iThemes.put(selected);
    return selected;
  }
});

final selectedThemeIdProvider = FutureProvider<int?>((ref) async {
  final isar = ref.read(isarProvider);
  final active = await isar.iThemes.where().sortByActiveAtDesc().findFirst();
  return active?.id;
});

final connectionsStreamProvider = Provider<Stream<List<Connection>>>((ref) {
  final isar = ref.read(isarProvider);
  final stream = isar.connections.where().build().watch(initialReturn: true);
  return stream;
});

typedef UpdateConnectionFields = bool? Function(Connection connection);

class ConnectionNotifier extends StateNotifier<Connection> {
  final Reader read;

  ConnectionNotifier(this.read) : super(Connection());

  void copyFrom(Connection connection) {
    this.state.copyFrom(connection);
  }

  void copySameFrom(Connection connection) {
    this.state.copySameFrom(connection);
  }

  void emptyFields() {
    this.state.emptyFields();
  }

  void updateField(UpdateConnectionFields update) {
    if (update(this.state) == true) {
      this.state = this.state;
    }
  }

  Future<void> save() async {
    final isar = read(isarProvider);
    if (this.state.id == null) {
      this.state.createAt = DateTime.now();
      this.state.color = LightColor.random();
    } else {
      this.state.updateAt = DateTime.now();
    }
    await isar.writeTxn((isar) async {
      return await isar.connections.put(this.state);
    });
  }
}

final editConnectionNotifierProvider =
    StateNotifierProvider<ConnectionNotifier, Connection>(
        (ref) => ConnectionNotifier(ref.read));

final tableCartExpandedProvider = StateProvider((ref) => false);
final tableCartItemProvider = ScopedProvider<Table>(null);

final tableCartProvider =
    Provider<Map<String, Map<String, List<Table>>>>((ref) {
  final mapped = ref.watch(selectedTableProvider);
  final tables = mapped.values;
  final grouped = <String, Map<String, List<Table>>>{};
  for (final value in tables) {
    ((grouped[value.connection.title] ??= {})[value.db] ??= []).add(value);
  }
  return grouped;
});

final tableCartFloatKeysProvider = Provider<Iterable<Connection>>((ref) {
  final selected = ref.watch(selectedTableProvider);
  final keys = <int?, Connection>{}; // isar not support getter
  selected.values.forEach((element) {
    keys[element.connection.id] = element.connection;
  });
  return keys.values;
});

final tableCartFloatCountNotifierProvider =
    StateNotifierProvider<TableCartFloatCountNotifier, Tuple2<int, int>>(
        (ref) => TableCartFloatCountNotifier());

class TableCartFloatCountNotifier extends StateNotifier<Tuple2<int, int>> {
  TableCartFloatCountNotifier() : super(Tuple2(0, 0));
  int _preValue = 0;

  int get preValue => _preValue;

  void set(int value) {
    this._preValue = this.state.item2;
    this.state = Tuple2(this._preValue, value);
  }
}
