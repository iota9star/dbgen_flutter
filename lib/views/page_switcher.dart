import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

part 'page_switcher.g.dart';

@swidget
Widget sharedAxisTransitionPageSwitcher(BuildContext context, Widget child,
    {Color? fillColor, bool reverse = false}) {
  return PageTransitionSwitcher(
    reverse: reverse,
    transitionBuilder: (child, animation, secondaryAnimation) {
      return SharedAxisTransition(
        fillColor: fillColor ?? Theme.of(context).scaffoldBackgroundColor,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      );
    },
    child: child,
  );
}

@swidget
Widget fadeThroughTransitionPageSwitcher(BuildContext context, Widget child,
    {Color? fillColor, bool reverse = false}) {
  return PageTransitionSwitcher(
    transitionBuilder: (child, animation, secondaryAnimation) {
      return FadeThroughTransition(
        fillColor: fillColor ?? Theme.of(context).scaffoldBackgroundColor,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
    child: child,
  );
}

@swidget
Widget oc<T>(
  BuildContext context,
  OpenContainerBuilder<T> openBuilder,
  CloseContainerBuilder closedBuilder, {
  ContainerTransitionType transitionType = ContainerTransitionType.fade,
  RouteSettings? routeSettings,
  Color? openColor,
  Color? closeColor,
}) {
  final themeData = Theme.of(context);
  return OpenContainer(
    transitionType: transitionType,
    openElevation: 0.0,
    closedElevation: 0.0,
    openColor: openColor ?? themeData.scaffoldBackgroundColor,
    closedColor: closeColor ?? themeData.backgroundColor,
    routeSettings: routeSettings,
    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    openShape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    openBuilder: openBuilder,
    closedBuilder: closedBuilder,
  );
}
