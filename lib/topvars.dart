import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dbgen/ext/ext.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormatter = DateFormat("yyyy-MM-dd HH:mm");

const String monoFont = "mono";

final dbColors = <String, Color>{};
final tableColors = <String, Color>{};
final tableTagsColors = <String, Color>{};

final emptyList = const [];
final emptyMap = const {};

class DestinationItem {
  final String label;
  final String route;
  final IconData unselected;
  final IconData selected;

  const DestinationItem(this.label, this.route, this.unselected, this.selected);
}

class Routes {
  const Routes._();

  static const ROOT = "/";
  static const HOME = "/dbgen";
  static const DASHBOARD = "$HOME/dashboard";
  static const DATASOURCE = "$HOME/datasource";
  static const DATASOURCE_EDIT = "$HOME/datasource/edit";
  static const DB = "$HOME/db";
  static const DB_TABLE = "$HOME/db/table";
  static const TEMPLATE = "$HOME/template";
  static const TEMPLATE_DETAIL = "$HOME/template/detail";
  static const TEMPLATE_EDIT = "$HOME/template/edit";
  static const THEME = "$HOME/theme";
  static const ABOUT = "$HOME/about";
}

const destinationItems = const [
  const DestinationItem(
    "主页",
    Routes.DASHBOARD,
    FluentIcons.leaf_one_20_regular,
    FluentIcons.leaf_three_20_filled,
  ),
  const DestinationItem(
    "数据源",
    Routes.DATASOURCE,
    FluentIcons.layer_20_regular,
    FluentIcons.channel_20_filled,
  ),
  const DestinationItem(
    "模板",
    Routes.TEMPLATE,
    FluentIcons.receipt_20_regular,
    FluentIcons.receipt_cube_20_filled,
  ),
];

final controlButtonColors = [
  HexColor.fromHex("#fbb43a"),
  HexColor.fromHex("#3ec544"),
  HexColor.fromHex("#fa625c")
];
const controlButtonIcons = const [
  FluentIcons.subtract_24_regular,
  FluentIcons.add_24_regular,
  FluentIcons.dismiss_24_regular
];
const controlButtonTooltips = const ["最小化", "最大化", "关闭"];
final controlButtonActions = [
  () => appWindow.minimize(),
  () => appWindow.maximizeOrRestore(),
  () => appWindow.close(),
];

final contentPanelNavKey = GlobalKey<NavigatorState>();

const sizedBoxH4 = const SizedBox(height: 4.0);
const sizedBoxH8 = const SizedBox(height: 8.0);
const sizedBoxH12 = const SizedBox(height: 12.0);
const sizedBoxH16 = const SizedBox(height: 16.0);
const sizedBoxH24 = const SizedBox(height: 24.0);
const sizedBoxH36 = const SizedBox(height: 36.0);
const sizedBoxW12 = const SizedBox(width: 12.0);
const sizedBoxW16 = const SizedBox(width: 16.0);

const sysDB = const {
  "information_schema",
  "sys",
  "mysql",
  "performance_schema",
};
