import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/providers.dart';
import 'package:dbgen/topvars.dart';
import 'package:dbgen/views/about.dart';
import 'package:dbgen/views/dashboard.dart';
import 'package:dbgen/views/datasource.dart';
import 'package:dbgen/views/page_switcher.dart';
import 'package:dbgen/views/template.dart';
import 'package:dbgen/views/theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'panel.g.dart';

@hwidget
Widget menuPanel() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: const IntrinsicHeight(
            child: const NavRail(),
          ),
        ),
      );
    },
  );
}

@hwidget
Widget navRail(BuildContext context) {
  final extended = useProvider(navRailExtendedProvider).state;
  final selected = useProvider(navRailSelectedProvider).state;
  final selectedIndex =
      destinationItems.indexWhere((element) => element.route == selected.route);
  return NavigationRail(
    selectedIndex: selectedIndex,
    labelType: NavigationRailLabelType.none,
    extended: extended,
    onDestinationSelected: (index) {
      final item = destinationItems[index];
      context.read(navRailSelectedProvider).state = item;
      while (contentPanelNavKey.currentState!.canPop()) {
        contentPanelNavKey.currentState!.pop();
      }
      contentPanelNavKey.currentState!.pushNamed(item.route);
    },
    destinations: [
      for (int i = 0; i < destinationItems.length; i++)
        NavigationRailDestination(
          icon: Icon(destinationItems[i].unselected),
          selectedIcon: Icon(destinationItems[i].selected),
          label: Text(destinationItems[i].label),
        ),
    ],
    leading: const NavRailLeading(),
  );
}

@hwidget
Widget navRailLeading(BuildContext context) {
  final animation = NavigationRail.extendedAnimation(context);
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            key: const ValueKey('DBGen'),
            borderRadius: const BorderRadius.all(const Radius.circular(48)),
            onTap: () {
              context.read(navRailExtendedProvider).state =
                  !context.read(navRailExtendedProvider).state;
            },
            child: Container(
              width: 72.0 + (256 - 72) * animation.value,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const NavRailTopIcon(),
                  if (animation.value > 0.5)
                    SizedBox(width: 20.0 * animation.value),
                  if (animation.value > 0.5)
                    Opacity(
                      opacity: animation.value,
                      child: Text(
                        'DBGen',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                          fontFamily: monoFont,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

@hwidget
Widget navRailTopIcon(BuildContext context) {
  final extended = useProvider(navRailExtendedProvider).state;
  final themeData = Theme.of(context);
  return Icon(
    extended ? FluentIcons.cube_24_filled : FluentIcons.cube_24_regular,
    size: 32.0,
    color: themeData.primaryColor,
  );
}

@hwidget
Widget contentPanel() {
  return Stack(
    children: [
      Positioned.fill(
        child: const ContentPanelNavigator(),
      ),
      Positioned(
        top: 6.0,
        right: 0,
        left: 0,
        child: const ControlButtonGroup(),
      )
    ],
  );
}

@hwidget
Widget controlButtonGroup(BuildContext context) {
  final widgets = <Widget>[Expanded(child: MoveWindow())];
  final length = controlButtonColors.length;
  for (var i = 0; i < length; i++) {
    widgets.add(
      ProviderScope(
        overrides: [windowButtonIndexProvider.overrideWithValue(i)],
        child: const ControlButton(),
      ),
    );
  }
  widgets.add(const SizedBox(width: 6.0));
  return WindowTitleBarBox(
    child: Row(
      children: widgets,
    ),
  );
}

@hwidget
Widget controlButton(BuildContext context) {
  final index = useProvider(windowButtonIndexProvider);
  final hoverIndex = useProvider(windowButtonHoverIndexProvider).state;
  return MouseRegion(
    onEnter: (_) {
      context.read(windowButtonHoverIndexProvider).state = index;
    },
    onExit: (_) {
      context.read(windowButtonHoverIndexProvider).state = -1;
    },
    child: InkWell(
      onTap: controlButtonActions[index],
      borderRadius: const BorderRadius.all(const Radius.circular(16)),
      child: Tooltip(
        message: controlButtonTooltips[index],
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 12.0,
        ),
        decoration: const BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(4.0),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: controlButtonColors[index],
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 2.0,
              ),
            ],
          ),
          margin: const EdgeInsets.all(6.0),
          padding: const EdgeInsets.all(2.0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: hoverIndex == index ? 1.0 : 0.0,
            child: Icon(
              controlButtonIcons[index],
              size: 12.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
}

@swidget
Widget contentPanelNavigator() {
  return Navigator(
    restorationScopeId: 'content-panel-navigator-scope',
    key: contentPanelNavKey,
    initialRoute: Routes.DASHBOARD,
    onGenerateRoute: (settings) {
      settings.name.d();
      late Widget page;
      switch (settings.name) {
        case Routes.ROOT:
        case Routes.HOME:
          page = CupertinoActivityIndicator();
          break;
        case Routes.DASHBOARD:
          page = FadeThroughTransitionPageSwitcher(const DashboardPage());
          break;
        case Routes.TEMPLATE:
          page = FadeThroughTransitionPageSwitcher(const TemplatePage());
          break;
        case Routes.TEMPLATE_DETAIL:
          page = SharedAxisTransitionPageSwitcher(
            const TemplateDetailPage(),
            reverse: true,
          );
          break;
        case Routes.TEMPLATE_EDIT:
          page = SharedAxisTransitionPageSwitcher(
            const TemplateEditPage(),
            reverse: true,
          );
          break;
        case Routes.DATASOURCE:
          page = FadeThroughTransitionPageSwitcher(const DatasourcePage());
          break;
        case Routes.DATASOURCE_EDIT:
          page = SharedAxisTransitionPageSwitcher(
            const DatasourceEditPage(),
            reverse: true,
          );
          break;
        case Routes.DB:
          page = SharedAxisTransitionPageSwitcher(
            const DatasourceDetailPage(),
            reverse: true,
          );
          break;
        case Routes.DB_TABLE:
          page = SharedAxisTransitionPageSwitcher(
            const TablePage(),
            reverse: true,
          );
          break;
        case Routes.THEME:
          page = FadeThroughTransitionPageSwitcher(const ThemePage());
          break;
        case Routes.ABOUT:
          page = FadeThroughTransitionPageSwitcher(const AboutPage());
          break;
      }
      return MaterialPageRoute<void>(
        builder: (_) => page,
        settings: settings,
      );
    },
  );
}
