import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

@Collection()
class ITheme {
  @Id()
  int? id;
  late int activeAt;
  late bool canDelete;
  late bool autoMode;
  late bool isDark;
  @ColorTypeConverter()
  late Color primaryColor;
  @ColorTypeConverter()
  late Color accentColor;
  @ColorTypeConverter()
  late Color lightBackgroundColor;
  @ColorTypeConverter()
  late Color darkBackgroundColor;
  @ColorTypeConverter()
  late Color lightScaffoldBackgroundColor;
  @ColorTypeConverter()
  late Color darkScaffoldBackgroundColor;

  theme({bool darkTheme = true}) {
    final bool isDark = this.autoMode ? darkTheme : this.isDark;
    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryColor = this.primaryColor;
    final primaryColorBrightness = primaryColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final accentColor = this.accentColor;
    final accentColorBrightness = accentColor.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final scaffoldBackgroundColor = isDark
        ? this.darkScaffoldBackgroundColor
        : this.lightScaffoldBackgroundColor;
    final backgroundColor =
        isDark ? this.darkBackgroundColor : this.lightBackgroundColor;
    final navRailSelectedLabelStyle = TextStyle(
      fontSize: 18.0,
      height: 1.25,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    );
    ThemeData themeData = ThemeData(
      brightness: brightness,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        brightness: brightness,
      ),
      primaryColorBrightness: primaryColorBrightness,
      accentColorBrightness: accentColorBrightness,
      primaryColor: primaryColor,
      accentColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      backgroundColor: backgroundColor,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: backgroundColor,
        selectedLabelTextStyle: navRailSelectedLabelStyle,
        unselectedLabelTextStyle: navRailSelectedLabelStyle.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
          borderRadius: BorderRadius.zero,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor),
          borderRadius: BorderRadius.zero,
        ),
        prefixStyle: TextStyle(color: accentColor),
        focusColor: accentColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 4.0,
        ),
        hintStyle: TextStyle(
          height: 1.4,
        ),
        labelStyle: TextStyle(
          fontSize: 16.0,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentColor,
        selectionColor: accentColor,
        selectionHandleColor: accentColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          shape: const RoundedRectangleBorder(),
          minimumSize: Size(120.0, 48.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(),
      ),
    );
    return themeData;
  }
}

final defaultTheme = ITheme()
  ..activeAt = DateTime.now().millisecondsSinceEpoch
  ..canDelete = false
  ..autoMode = true
  ..isDark = false
  ..primaryColor = HexColor.fromHex("#33b18a")
  ..accentColor = HexColor.fromHex("#f5a623")
  ..lightBackgroundColor = Colors.white
  ..darkBackgroundColor = HexColor.fromHex("#1a1a35")
  ..lightScaffoldBackgroundColor = HexColor.fromHex("#f1f2f7")
  ..darkScaffoldBackgroundColor = HexColor.fromHex("#11142e");
