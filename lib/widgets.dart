import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

part 'widgets.g.dart';

@swidget
Widget ripple(
  BuildContext context,
  Widget child,
  VoidCallback onTap, {
  Color? effectColor,
  Color? backgroundColor,
}) {
  final themeData = Theme.of(context);
  return Material(
    child: Ink(
      color: backgroundColor ?? themeData.backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: child,
        splashColor: effectColor ?? themeData.scaffoldBackgroundColor,
        hoverColor: effectColor ?? themeData.scaffoldBackgroundColor,
        focusColor: effectColor ?? themeData.scaffoldBackgroundColor,
        enableFeedback: true,
      ),
    ),
  );
}

@swidget
Widget normalHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(
      left: 24.0,
      right: 24.0,
      bottom: 12.0,
      top: 40.0,
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        height: 1.25,
      ),
      textAlign: TextAlign.justify,
    ),
  );
}
