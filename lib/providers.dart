import 'dart:async';

import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isar.g.dart';
import 'package:dbgen/model/db.dart';
import 'package:dbgen/model/theme.dart';
import 'package:dbgen/repo/db_repo.dart';
import 'package:dbgen/topvars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:tuple/tuple.dart';

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
  await repo.connect(connection.toSettings());
  return repo;
});

final groupedTablesProvider =
    FutureProvider.autoDispose<Map<String, Iterable<Table>>>((ref) async {
  final repo = await ref.watch(dbRepoProvider.future);
  ref.read(tableSearchProvider.notifier).state = "";
  ref.read(dbFilterProvider.notifier).clear();
  final showSys = ref.watch(showSysDBProvider).state;
  final groupTables = await repo.groupedTables();
  if (!showSys) {
    final noSys = <String, Iterable<Table>>{};
    groupTables.forEach((key, value) {
      if (!sysDB.contains(key.toLowerCase())) {
        noSys[key] = value;
      }
    });
    return noSys;
  }
  return groupTables;
});

final filteredGroupedTablesProvider =
    FutureProvider.autoDispose<Map<String, Iterable<Table>>>((ref) async {
  final filters = ref.watch(dbFilterProvider);
  final keywords = ref.watch(tableSearchProvider).state;
  final grouped = ref.watch(groupedTablesProvider);
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
  final full = await ref.watch(groupedTablesProvider.future);
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
        (ref) => SelectedTableNotifier());

class SelectedTableNotifier extends StateNotifier<Map<String, Table>> {
  SelectedTableNotifier() : super({});

  operator []=(String key, Table value) {
    this.state[key] = value;
    notifyListeners();
  }

  void remove(String key) {
    this.state.remove(key);
    notifyListeners();
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
