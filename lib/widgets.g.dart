// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widgets.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class Ripple extends StatelessWidget {
  const Ripple(this.child, this.onTap,
      {Key? key, this.effectColor, this.backgroundColor})
      : super(key: key);

  final Widget child;

  final void Function() onTap;

  final Color? effectColor;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext _context) => ripple(_context, child, onTap,
      effectColor: effectColor, backgroundColor: backgroundColor);
}

class NormalHeader extends StatelessWidget {
  const NormalHeader(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext _context) => normalHeader(title);
}
