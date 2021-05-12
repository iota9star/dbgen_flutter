import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/isar.g.dart';
import 'package:dbgen/model/theme.dart';
import 'package:dbgen/providers.dart';
import 'package:dbgen/topvars.dart';
import 'package:dbgen/views/panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'main.g.dart';

void main() async {
  // final path = Directory.current.path + Platform.pathSeparator + "isar";
  // final dir = Directory(path);
  // final exist = await dir.exists();
  // if (!exist) {
  //   await dir.create(recursive: true);
  // }
  final isar = await openIsar(name: "db", directory: Directory.current.path);
  runApp(
    ProviderScope(
      observers: [
        const RiverpodLogger(),
      ],
      overrides: [rootIsarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
  doWhenWindowReady(() {
    appWindow.minSize = Size(640, 480);
    appWindow.size = Size(960, 640);
    appWindow.alignment = Alignment.center;
    appWindow.title = "DBGen";
    appWindow.show();
  });
}

@hwidget
Widget myApp() {
  final selectedTheme = useProvider(selectedThemeProvider);
  return selectedTheme.when(data: (theme) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.ROOT,
      theme: theme.theme(),
      darkTheme: theme.theme(darkTheme: true),
      themeMode: ThemeMode.system,
      onGenerateRoute: (settings) {
        settings.name.d();
        switch (settings.name) {
          case Routes.ROOT:
            return MaterialPageRoute<void>(
              builder: (context) => const HomePage(),
              settings: settings,
            );
        }
        return null;
      },
    );
  }, loading: () {
    return CupertinoActivityIndicator();
  }, error: (_, __) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.ROOT,
      theme: defaultTheme.theme(),
      darkTheme: defaultTheme.theme(darkTheme: true),
      onGenerateRoute: (settings) {
        settings.name.d();
        switch (settings.name) {
          case Routes.ROOT:
            return MaterialPageRoute<void>(
              builder: (context) => const HomePage(),
              settings: settings,
            );
        }
        return null;
      },
    );
  });
}

@swidget
Widget homePage() {
  return Scaffold(
    body: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const MenuPanel(),
        const Expanded(child: const ContentPanel()),
      ],
    ),
  );
}
