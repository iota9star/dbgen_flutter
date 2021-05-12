// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_switcher.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class SharedAxisTransitionPageSwitcher extends StatelessWidget {
  const SharedAxisTransitionPageSwitcher(this.child,
      {Key? key, this.fillColor, this.reverse = false})
      : super(key: key);

  final Widget child;

  final Color? fillColor;

  final bool reverse;

  @override
  Widget build(BuildContext _context) =>
      sharedAxisTransitionPageSwitcher(_context, child,
          fillColor: fillColor, reverse: reverse);
}

class FadeThroughTransitionPageSwitcher extends StatelessWidget {
  const FadeThroughTransitionPageSwitcher(this.child,
      {Key? key, this.fillColor, this.reverse = false})
      : super(key: key);

  final Widget child;

  final Color? fillColor;

  final bool reverse;

  @override
  Widget build(BuildContext _context) =>
      fadeThroughTransitionPageSwitcher(_context, child,
          fillColor: fillColor, reverse: reverse);
}

class Oc<T> extends StatelessWidget {
  const Oc(this.openBuilder, this.closedBuilder,
      {Key? key,
      this.transitionType = ContainerTransitionType.fade,
      this.routeSettings,
      this.openColor,
      this.closeColor})
      : super(key: key);

  final Widget Function(BuildContext, void Function({T? returnValue}))
      openBuilder;

  final Widget Function(BuildContext, void Function()) closedBuilder;

  final ContainerTransitionType transitionType;

  final RouteSettings? routeSettings;

  final Color? openColor;

  final Color? closeColor;

  @override
  Widget build(BuildContext _context) =>
      oc<T>(_context, openBuilder, closedBuilder,
          transitionType: transitionType,
          routeSettings: routeSettings,
          openColor: openColor,
          closeColor: closeColor);
}
