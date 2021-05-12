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
  final themeData = Theme.of(context);
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
      for (final item in destinationItems)
        NavigationRailDestination(
          padding: EdgeInsets.zero,
          icon: Icon(
            item.unselected,
            size: 32.0,
          ),
          selectedIcon: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  themeData.primaryColor,
                  themeData.accentColor,
                ],
                tileMode: TileMode.repeated,
              ).createShader(bounds);
            },
            child: Icon(
              item.selected,
              size: 32.0,
            ),
          ),
          label: Text(
            item.label,
            style: const TextStyle(
              fontSize: 18.0,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
    leading: const NavRailLeading(),
  );
}

@hwidget
Widget navRailLeading(BuildContext context) {
  final animation = NavigationRail.extendedAnimation(context);
  final extended = useProvider(navRailExtendedProvider).state;
  final themeData = Theme.of(context);
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
                  ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (Rect bounds) {
                      return RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          themeData.accentColor,
                          themeData.primaryColor,
                        ],
                        tileMode: TileMode.repeated,
                      ).createShader(bounds);
                    },
                    child: Icon(
                      extended
                          ? FluentIcons.cube_24_filled
                          : FluentIcons.cube_24_regular,
                      size: 32.0,
                    ),
                  ),
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
Widget contentPanel() {
  return Stack(
    children: [
      Positioned.fill(
        child: const SharedAxisTransitionPageSwitcher(
          const ContentPanelNavigator(),
          reverse: true,
        ),
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
  final index = useProvider(windowButtonHoverIndexProvider).state;
  final widgets = <Widget>[Expanded(child: MoveWindow())];
  final length = controlButtonColors.length;
  for (var i = 0; i < length; i++) {
    widgets.add(MouseRegion(
      onEnter: (_) {
        context.read(windowButtonHoverIndexProvider).state = i;
      },
      onExit: (_) {
        context.read(windowButtonHoverIndexProvider).state = -1;
      },
      child: InkWell(
        onTap: controlButtonActions[i],
        borderRadius: const BorderRadius.all(const Radius.circular(16)),
        child: Tooltip(
          message: controlButtonTooltips[i],
          textStyle: TextStyle(
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
              color: controlButtonColors[i],
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                ),
              ],
            ),
            margin: const EdgeInsets.all(6.0),
            padding: const EdgeInsets.all(2.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: index == i ? 1.0 : 0.0,
              child: Icon(
                controlButtonIcons[i],
                size: 12.0,
              ),
            ),
          ),
        ),
      ),
    ));
  }
  widgets.add(const SizedBox(width: 6.0));
  return WindowTitleBarBox(
    child: Row(
      children: widgets,
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
          page = FadeThroughTransitionPageSwitcher(DashboardPage());
          break;
        case Routes.TEMPLATE:
          page = FadeThroughTransitionPageSwitcher(TemplatePage());
          break;
        case Routes.TEMPLATE_DETAIL:
          page = SharedAxisTransitionPageSwitcher(
            TemplateDetailPage(),
            reverse: true,
          );
          break;
        case Routes.TEMPLATE_EDIT:
          page = SharedAxisTransitionPageSwitcher(
            TemplateEditPage(),
            reverse: true,
          );
          break;
        case Routes.DATASOURCE:
          page = FadeThroughTransitionPageSwitcher(DatasourcePage());
          break;
        case Routes.DATASOURCE_EDIT:
          page = SharedAxisTransitionPageSwitcher(
            DatasourceEditPage(),
            reverse: true,
          );
          break;
        case Routes.DB:
          page = SharedAxisTransitionPageSwitcher(
            DatasourceDetailPage(),
            reverse: true,
          );
          break;
        case Routes.THEME:
          page = FadeThroughTransitionPageSwitcher(ThemePage());
          break;
        case Routes.ABOUT:
          page = FadeThroughTransitionPageSwitcher(AboutPage());
          break;
      }
      return MaterialPageRoute<void>(
        builder: (_) => page,
        settings: settings,
      );
    },
  );
}
