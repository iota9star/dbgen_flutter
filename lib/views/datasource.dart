import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isar.g.dart';
import 'package:dbgen/providers.dart';
import 'package:dbgen/topvars.dart';
import 'package:dbgen/views/page_switcher.dart';
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

part 'datasource.g.dart';

@hwidget
Widget datasourcePage(BuildContext context) {
  return Container(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        const DatasourceHeader(),
        const Expanded(child: const DatasourceFragment()),
      ],
    ),
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
      mainAxisExtent: 146.0,
    ),
  );
}

@hwidget
Widget addDatasourceItem(BuildContext context) {
  final themeData = Theme.of(context);
  return Oc(
    (_, action) {
      context.read(editConnectionNotifierProvider.notifier).emptyFields();
      return const DatasourceEditPage();
    },
    (context, action) {
      return Container(
        color: themeData.backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(FluentIcons.add_24_regular),
                onPressed: action,
              ),
              sizedBoxH8,
              const Text("创建新的数据源")
            ],
          ),
        ),
      );
    },
    routeSettings: RouteSettings(name: Routes.DATASOURCE_EDIT),
  );
}

@hwidget
Widget datasourceItem(BuildContext context) {
  final connection = useProvider(connectionItemProvider)!;
  final themeData = Theme.of(context);
  final bgc = themeData.backgroundColor;
  return Oc(
    (_, __) {
      context
          .read(selectedConnectNotifierProvider.notifier)
          .copyFrom(connection);
      return const DatasourceDetailPage();
    },
    (_, action) {
      return GestureDetector(
        onTap: action,
        child: Container(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 8.0,
            top: 16.0,
          ),
          decoration: BoxDecoration(
            color: bgc,
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
                              ? "暂无描述"
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
                "主机地址: ${connection.host}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 12.0,
                  fontFamily: monoFont,
                ),
              ),
              Text(
                "端口: ${connection.port}",
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
                          ? "上次连接: ${dateFormatter.format(connection.lastOpenAt!)}"
                          : connection.updateAt != null
                              ? "上次修改: ${dateFormatter.format(connection.updateAt!)}"
                              : "创建时间: ${dateFormatter.format(connection.createAt)}",
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
                    tooltip: "更多",
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
                          child: Text("编辑"),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("从当前新增"),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
    routeSettings: RouteSettings(name: Routes.DB),
  );
}

@swidget
Widget datasourceHeader() {
  return const NormalHeader("我的数据源");
}

@swidget
Widget normalHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 24.0,
      right: 24.0,
      bottom: 12.0,
      top: 24.0,
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        height: 1.25,
      ),
    ),
  );
}

@swidget
Widget datasourceDetailPage() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
  final themeData = Theme.of(context);
  final bgc = themeData.backgroundColor;
  final groupTables = useProvider(filteredGroupedTablesProvider);
  "build table fragment".d();
  return CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: groupTables.when(
      data: (data) {
        return data.entries.map(
          (entry) {
            return MultiSliver(
              pushPinnedChildren: true,
              children: <Widget>[
                SliverPinnedToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                    decoration: BoxDecoration(
                      color: bgc,
                      border: Border(
                        left: BorderSide(
                          color: dbColors[entry.key] ?? bgc,
                          width: 4.0,
                        ),
                      ),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        height: 1.25,
                        fontSize: 20.0,
                        fontFamily: monoFont,
                      ),
                    ),
                  ),
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
                  "加载中，请稍候...",
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
Widget tableItemProviderScope() {
  final table = useProvider(tableItemProvider);
  final selected = useProvider(
      selectedTableProvider.select((value) => value.containsKey(table.id)));
  "build table item provider scope".d();
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
      top: 24.0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "数据源：${connect.title}",
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
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
              physics: const BouncingScrollPhysics(),
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
  return NormalHeader(connection?.id != null ? "编辑数据源" : "新增数据源");
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
            hintText: "请填写连接名称",
            labelText: "连接名称 *",
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
            hintText: "请填写连接描述",
            labelText: "连接描述",
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
            hintText: "请填写主机地址",
            labelText: "主机地址 *",
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
            hintText: "请填写端口",
            labelText: "端口 *",
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
            hintText: "请填写用户名",
            labelText: "用户名",
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
            hintText: "请填写密码",
            labelText: "密码",
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
          hint: Text("选择编码方式"),
          onChanged: (int? value) {
            context
                .read(editConnectionNotifierProvider.notifier)
                .updateField((conn) {
              conn.charset = value;
            });
          },
        ),
        sizedBoxH16,
        SwitchListTile(
          title: Text("启用SSL"),
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
          title: Text("启用压缩"),
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
                  child: Text("测试连接"),
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
                          content: Text("保存成功"),
                          onVisible: () {
                            contentPanelNavKey.currentState!.pop();
                          },
                        ),
                      );
                    });
                  },
                  child: Text("保存数据源"),
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
        labelText: "搜索",
        labelStyle: TextStyle(fontSize: 14.0),
        hintText: "请输入关键字",
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
        var base = "数据库  ${data.item1}个，表/视图  ${data.item2}个。";
        if (data.item2 != data.item4) {
          base += "  过滤结果 数据库  ${data.item3}个，表/视图  ${data.item4}个。";
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
Widget dbFilters(BuildContext context) {
  final groupedTable = useProvider(groupedTablesProvider);
  final filters = useProvider(dbFilterProvider);
  final bgc = Theme.of(context).backgroundColor;
  return groupedTable.when(
    data: (data) {
      final int length = data.length;
      if (length == 0) {
        return SizedBox();
      }
      final List<Widget> chips = data.keys.map((db) {
        final selected = filters.contains(db);
        final selectedColor = selected ? dbColors[db] : null;
        final textColor =
            (selectedColor == null ? bgc : selectedColor).computeLuminance() >
                    0.5
                ? Colors.black
                : Colors.white;
        return FilterChip(
          shape: const RoundedRectangleBorder(),
          selectedColor: selectedColor,
          selectedShadowColor: selectedColor,
          label: Text(db),
          checkmarkColor: textColor,
          backgroundColor: bgc,
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
      }).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: const Text(
              "数据库",
              style: const TextStyle(
                height: 1.25,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: monoFont,
              ),
            ),
          ),
          Wrap(
            children: chips,
            runSpacing: 8.0,
            spacing: 8.0,
          ),
        ],
      );
    },
    loading: () => CupertinoActivityIndicator(),
    error: (_, __) => Text("${_},${__}"),
  );
}

@hwidget
Widget tableItem(BuildContext context) {
  final themeData = Theme.of(context);
  final bgc = themeData.backgroundColor;
  final table = useProvider(tableItemProvider);
  final isSelected = useProvider(tableItemIsSelectedProvider);
  "build_table: ${table.id}".d();
  return GestureDetector(
    onTap: () {
      if (isSelected) {
        context.read(selectedTableProvider.notifier).remove(table.id);
      } else {
        context.read(selectedTableProvider.notifier)[table.id] = table;
      }
    },
    child: AnimatedContainer(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 8.0,
        top: 16.0,
      ),
      decoration: BoxDecoration(
        color: bgc,
        border: Border.all(
          color: isSelected ? dbColors[table.db] ?? bgc : bgc,
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
                      table.comment.isNullOrBlank ? "暂无备注" : table.comment!,
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
                  style: TextStyle(
                    height: 1.25,
                    fontSize: 12.0,
                    fontFamily: monoFont,
                  ),
                ),
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    FluentIcons.more_horizontal_24_regular,
                  ),
                ),
                onTap: () {
                  contentPanelNavKey.currentState!.pushNamed(Routes.DB_TABLE);
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}
