import 'package:flutter/widgets.dart';

Widget counterTransitionBuilder(
    ValueKey key, bool up, Widget child, Animation<double> animation) {
  var dy = key == child.key ? -1.0 : 1.0;
  if (up) dy = -dy;
  return ClipRect(
    child: SlideTransition(
      position: Tween<Offset>(begin: Offset(0.0, dy), end: Offset(0.0, 0.0))
          .animate(animation),
      child: child,
    ),
  );
}
