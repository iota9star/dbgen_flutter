import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isar.g.dart';
import 'package:dbgen/providers.dart';
import 'package:dbgen/topvars.dart';
import 'package:dbgen/views/page_switcher.dart';
import 'package:dbgen/widgets.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mysql1/mysql1.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../providers.dart';

part 'datasource.g.dart';

@swidget
Widget datasourcePage() {
  return const BasePage(
    children: const [
      const DatasourceHeader(),
      const Expanded(child: const DatasourceFragment()),
    ],
  );
}

@hwidget
Widget datasourceFragment() {
  final isar = useProvider(isarProvider);
  final stream = useMemoized(() =>
      isar.connections.where().sortByUpdateAtDesc().watch(initialReturn: true));
  final asyncData = useStream(stream, initialData: []);
  final list = asyncData.data ?? [];
  final isEmpty = list.isEmpty;
  return GridView.builder(
    padding: const EdgeInsets.only(
      left: 24.0,
      right: 24.0,
      bottom: 16.0,
      top: 12.0,
    ),
    itemBuilder: (_, index) {
      if (isEmpty) {
        return const AddDatasourceItem();
      }
      return ProviderScope(
        overrides: [
          connectionItemProvider.overrideWithValue(list[index]),
        ],
        child: const DatasourceItem(),
      );
    },
    itemCount: isEmpty ? 1 : list.length,
    gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      minCrossAxisExtent: 300.0,
      mainAxisExtent: 150.0,
    ),
  );
}

@hwidget
Widget addDatasourceItem(BuildContext context) {
  final themeData = Theme.of(context);
  return Oc(
    (_, __) {
      context.read(editConnectionNotifierProvider.notifier).emptyFields();
      return const DatasourceEditPage();
    },
    (_, action) {
      return Ripple(
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeData.backgroundColor,
              width: 4.0,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.add_24_regular),
                sizedBoxH8,
                const Text("?????????????????????")
              ],
            ),
          ),
        ),
        action,
      );
    },
    routeSettings: const RouteSettings(name: Routes.DATASOURCE_EDIT),
  );
}

@hwidget
Widget datasourceItem(BuildContext context) {
  final connection = useProvider(connectionItemProvider)!;
  final themeData = Theme.of(context);
  return Oc(
    (_, __) {
      context
          .read(selectedConnectNotifierProvider.notifier)
          .copyFrom(connection);
      return const DatasourceDetailPage();
    },
    (_, action) {
      return Ripple(
        Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 8.0,
            top: 16.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeData.backgroundColor,
              width: 4.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.0,
                    backgroundColor: connection.color,
                    child: Text(
                      connection.title.characters.first.toUpperCase(),
                      style: TextStyle(
                        height: 1.25,
                        color: connection.color.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: monoFont,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.0,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            fontFamily: monoFont,
                          ),
                        ),
                        Text(
                          connection.desc.isNullOrBlank
                              ? "????????????"
                              : connection.desc!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.0,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              sizedBoxH12,
              Text(
                "????????????: ${connection.host}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 12.0,
                  fontFamily: monoFont,
                ),
              ),
              Text(
                "??????: ${connection.port}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 12.0,
                  fontFamily: monoFont,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      connection.lastOpenAt != null
                          ? "????????????: ${dateFormatter.format(connection.lastOpenAt!)}"
                          : connection.updateAt != null
                              ? "????????????: ${dateFormatter.format(connection.updateAt!)}"
                              : "????????????: ${dateFormatter.format(connection.createAt)}",
                      style: TextStyle(
                        height: 1.25,
                        fontSize: 12.0,
                        fontFamily: monoFont,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    icon: Icon(
                      FluentIcons.more_horizontal_24_regular,
                    ),
                    tooltip: "??????",
                    onSelected: (value) {
                      if (value == 1) {
                        context
                            .read(editConnectionNotifierProvider.notifier)
                            .copyFrom(connection);
                        contentPanelNavKey.currentState!
                            .pushNamed(Routes.DATASOURCE_EDIT);
                      } else if (value == 2) {
                        context
                            .read(editConnectionNotifierProvider.notifier)
                            .copySameFrom(connection);
                        contentPanelNavKey.currentState!
                            .pushNamed(Routes.DATASOURCE_EDIT);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 1,
                          child: Text("??????"),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("???????????????"),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        action,
      );
    },
    routeSettings: const RouteSettings(name: Routes.DB),
  );
}

@swidget
Widget datasourceHeader() {
  return const NormalHeader("???????????????");
}

@swidget
Widget datasourceDetailPage() {
  return const BasePage(
    children: const [
      const DatasourceDetailHeader(),
      const Expanded(
        child: const Scrollbar(
          child: const TableSections(),
        ),
      ),
    ],
  );
}

@hwidget
Widget tableSections(BuildContext context) {
  final groupTables = useProvider(filteredGroupedTablesProvider);
  return CustomScrollView(
    physics: const ClampingScrollPhysics(),
    slivers: groupTables.when(
      data: (data) {
        return data.entries.map(
          (entry) {
            return MultiSliver(
              pushPinnedChildren: true,
              children: <Widget>[
                ProviderScope(
                  overrides: [
                    dbSectionKeyProvider.overrideWithValue(entry.key)
                  ],
                  child: const DbSection(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 16.0,
                    top: 16.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMinCrossAxisExtent(
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      minCrossAxisExtent: 300.0,
                      mainAxisExtent: 108.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        final table = entry.value.elementAt(index);
                        return ProviderScope(
                          overrides: [
                            tableItemProvider.overrideWithValue(table),
                          ],
                          child: const TableItemProviderScope(),
                        );
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList();
      },
      loading: () => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 36.0,
              horizontal: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CupertinoActivityIndicator(),
                sizedBoxW12,
                const Text(
                  "?????????????????????...",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
      error: (err, stack) {
        print(err);
        print(stack);
        return [SliverToBoxAdapter(child: Text("erro"))];
      },
    ),
  );
}

@hwidget
Widget dbSection(BuildContext context) {
  final themeData = Theme.of(context);
  return SliverPinnedToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      color: themeData.backgroundColor,
      child: const DbSectionCheckbox(),
    ),
  );
}

@hwidget
Widget dbSectionCheckbox(BuildContext context) {
  final key = useProvider(dbSectionKeyProvider);
  final value = useProvider(dbCheckStateProvider.select((map) => map[key]));
  return CheckboxListTile(
    value: value,
    tristate: true,
    activeColor: dbColors[key],
    onChanged: (bool? newValue) {
      if (value == null || newValue == true) {
        context.read(selectedTableProvider.notifier).check(key);
      } else {
        context.read(selectedTableProvider.notifier).uncheck(key);
      }
    },
    title: Text(
      key,
      style: const TextStyle(
        height: 1.25,
        fontSize: 20.0,
        fontFamily: monoFont,
      ),
    ),
    secondary: Icon(
      value == true
          ? FluentIcons.layer_24_filled
          : FluentIcons.layer_24_regular,
      color: dbColors[key],
    ),
  );
}

@hwidget
Widget tableItemProviderScope() {
  final table = useProvider(tableItemProvider);
  final selected = useProvider(
      selectedTableProvider.select((value) => value.containsKey(table.id)));
  return ProviderScope(
    overrides: [tableItemIsSelectedProvider.overrideWithValue(selected)],
    child: const TableItem(),
  );
}

@hwidget
Widget datasourceDetailHeader() {
  final connect = useProvider(selectedConnectNotifierProvider);
  return Padding(
    padding: const EdgeInsets.only(
      left: 24.0,
      right: 24.0,
      top: 40.0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "????????????${connect.title}",
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
          textAlign: TextAlign.justify,
        ),
        sizedBoxH12,
        const TableSearchBar(),
        sizedBoxH12,
        const DbFilters(),
        sizedBoxH12,
        const TableFilterResult(),
        sizedBoxH12,
      ],
    ),
  );
}

@swidget
Widget datasourceEditPage(BuildContext context) {
  final themeData = Theme.of(context);
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: themeData.scaffoldBackgroundColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DatasourceEditHeader(),
        const Expanded(
          child: const Scrollbar(
            child: const SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const DatasourceEditForm(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@hwidget
Widget datasourceEditHeader() {
  final connection = useProvider(connectionItemProvider);
  return NormalHeader(connection?.id != null ? "???????????????" : "???????????????");
}

@hwidget
Widget datasourceEditForm(BuildContext context) {
  final themeData = Theme.of(context);
  final connection = useProvider(editConnectionNotifierProvider);
  return Form(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBoxH8,
        TextFormField(
          initialValue: connection.title,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "?????????????????????",
            labelText: "???????????? *",
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.title = value;
            });
          },
        ),
        sizedBoxH16,
        TextFormField(
          initialValue: connection.desc,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "?????????????????????",
            labelText: "????????????",
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.desc = value;
            });
          },
        ),
        sizedBoxH16,
        TextFormField(
          initialValue: connection.host,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "?????????????????????",
            labelText: "???????????? *",
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.host = value;
            });
          },
        ),
        sizedBoxH16,
        TextFormField(
          initialValue: connection.port.toString(),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "???????????????",
            labelText: "?????? *",
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (!value.isNullOrBlank) {
              context
                  .read(editConnectionNotifierProvider.notifier)
                  .updateField((conn) {
                conn.port = int.parse(value);
              });
            }
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        sizedBoxH16,
        TextFormField(
          initialValue: connection.user,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "??????????????????",
            labelText: "?????????",
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.user = value;
            });
          },
        ),
        sizedBoxH16,
        TextFormField(
          initialValue: connection.password,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "???????????????",
            labelText: "??????",
          ),
          keyboardType: TextInputType.visiblePassword,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.password = value;
            });
          },
        ),
        sizedBoxH16,
        DropdownButtonFormField(
          value: connection.charset,
          items: [
            DropdownMenuItem<int>(
              child: Text("UTF8"),
              value: CharacterSet.UTF8,
            ),
            DropdownMenuItem<int>(
              child: Text("UTF8MB4"),
              value: CharacterSet.UTF8MB4,
            ),
          ],
          hint: Text("??????????????????"),
          onChanged: (int? value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.charset = value ?? CharacterSet.UTF8MB4;
            });
          },
        ),
        sizedBoxH16,
        SwitchListTile(
          title: Text("??????SSL"),
          value: connection.useSSL,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.useSSL = value;
              return true;
            });
          },
        ),
        sizedBoxH16,
        SwitchListTile(
          title: Text("????????????"),
          value: connection.useCompression,
          onChanged: (value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.useCompression = value;
              return true;
            });
          },
        ),
        sizedBoxH16,
        Row(
          children: [
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("????????????"),
                  style: ElevatedButton.styleFrom(
                    primary: themeData.accentColor,
                  ),
                ),
              ),
            ),
            sizedBoxW16,
            Flexible(
              child: FractionallySizedBox(
                widthFactor: 1,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read(editConnectionNotifierProvider.notifier)
                        .save()
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("????????????"),
                          onVisible: () {
                            contentPanelNavKey.currentState!.pop();
                          },
                        ),
                      );
                    });
                  },
                  child: Text("???????????????"),
                ),
              ),
            ),
          ],
        ),
        sizedBoxH36,
      ],
    ),
  );
}

@hwidget
Widget tableSearchBar(BuildContext context) {
  final themeData = Theme.of(context);
  return Container(
    width: 320.0,
    child: TextField(
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: themeData.accentColor),
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ),
        labelText: "??????",
        labelStyle: TextStyle(fontSize: 14.0),
        hintText: "??????????????????",
      ),
      style: TextStyle(fontSize: 14.0),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onSubmitted: (value) {
        context.read(tableSearchProvider).state = value;
      },
    ),
  );
}

@hwidget
Widget tableFilterResult() {
  final filtered = useProvider(filteredTableProvider);
  return filtered.when(
      data: (data) {
        var base = "?????????  ${data.item1}?????????/??????  ${data.item2}??????";
        if (data.item2 != data.item4) {
          base += "  ???????????? ?????????  ${data.item3}?????????/??????  ${data.item4}??????";
        }
        return Text(
          base,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        );
      },
      loading: () => SizedBox(),
      error: (_, __) => SizedBox());
}

@hwidget
Widget dbFilters() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            "?????????",
            style: const TextStyle(
              height: 1.25,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: monoFont,
            ),
          ),
          const Spacer(),
          const Text("????????????????????? "),
          const ShowSysSwitch(),
        ],
      ),
      sizedBoxH8,
      const DbItems(),
    ],
  );
}

@hwidget
Widget showSysSwitch(BuildContext context) {
  final showSys = useProvider(showSysDBProvider).state;
  final themeData = Theme.of(context);
  return Checkbox(
    value: showSys,
    activeColor: themeData.primaryColor,
    onChanged: (value) {
      context.read(showSysDBProvider.notifier).state = value ?? false;
    },
  );
}

@hwidget
Widget dbItems(BuildContext context) {
  final groupedTable = useProvider(dbTablesProvider);
  return groupedTable.when(
      data: (data) {
        final int length = data.length;
        if (length == 0) {
          return SizedBox();
        }
        final keys = data.keys;
        return Wrap(
          children: [
            for (var item in keys)
              ProviderScope(
                overrides: [dbKeyProvider.overrideWithValue(item)],
                child: const DbItem(),
              )
          ],
          runSpacing: 8.0,
          spacing: 8.0,
        );
      },
      loading: () => SizedBox(),
      error: (_, __) => SizedBox());
}

@hwidget
Widget dbItem(BuildContext context) {
  final themeData = Theme.of(context);
  final db = useProvider(dbKeyProvider);
  final selected =
      useProvider(dbFilterProvider.select((value) => value.contains(db)));
  final selectedColor = selected ? dbColors[db] : null;
  final textColor =
      (selectedColor == null ? themeData.backgroundColor : selectedColor)
                  .computeLuminance() >
              0.5
          ? Colors.black
          : Colors.white;
  return FilterChip(
    shape: const RoundedRectangleBorder(),
    selectedColor: selectedColor,
    selectedShadowColor: selectedColor,
    label: Text(db),
    checkmarkColor: textColor,
    backgroundColor: themeData.backgroundColor,
    labelStyle: TextStyle(
      height: 1.25,
      fontSize: 14.0,
      fontFamily: monoFont,
      color: textColor,
    ),
    onSelected: (selected) {
      if (selected) {
        context.read(dbFilterProvider.notifier).add(db);
      } else {
        context.read(dbFilterProvider.notifier).remove(db);
      }
    },
    selected: selected,
  );
}

@hwidget
Widget tableItem(BuildContext context) {
  final themeData = Theme.of(context);
  final table = useProvider(tableItemProvider);
  final isSelected = useProvider(tableItemIsSelectedProvider);
  return Ripple(
    AnimatedContainer(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 8.0,
        top: 16.0,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? dbColors[table.db] ?? themeData.backgroundColor
              : themeData.backgroundColor,
          width: 4.0,
        ),
      ),
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.0,
                backgroundColor: table.color,
                child: Text(
                  table.name.characters.first.toUpperCase(),
                  style: TextStyle(
                    height: 1.25,
                    color: table.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.w500,
                    fontFamily: monoFont,
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        fontFamily: monoFont,
                      ),
                    ),
                    Text(
                      table.comment.isNullOrBlank ? "????????????" : table.comment!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  dateFormatter.format(table.updateAt ?? table.createAt),
                  style: const TextStyle(
                    height: 1.25,
                    fontSize: 12.0,
                    fontFamily: monoFont,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  FluentIcons.more_horizontal_24_regular,
                ),
                onPressed: () {
                  contentPanelNavKey.currentState!.pushNamed(Routes.DB_TABLE);
                },
              )
            ],
          )
        ],
      ),
    ),
    () {
      if (isSelected) {
        context.read(selectedTableProvider.notifier).remove(table.id);
      } else {
        context.read(selectedTableProvider.notifier)[table.id] = table;
      }
    },
  );
}

@swidget
Widget tablePage() {
  return const BasePage(
    children: const [const TableHeader()],
  );
}

@hwidget
Widget tableHeader() {
  return const NormalHeader("");
}
