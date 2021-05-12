import 'dart:async';
import 'dart:collection';

import 'package:dbgen/ext/ext.dart';
import 'package:flutter/foundation.dart';

class Log {
  const Log._();

  static void p(dynamic msg, {int wrapWidth = 800, String tag = "DEBUG"}) {
    if (kDebugMode) {
      _debugPrintThrottled(
        msg.toString(),
        wrapWidth: wrapWidth + tag.length,
        tag: tag,
      );
    }
  }
}

/// Implementation of [debugPrint] that throttles messages. This avoids dropping
/// messages on platforms that rate-limit their logging (for example, Android).
void _debugPrintThrottled(String? message, {int? wrapWidth, String? tag}) {
  final List<String> messageLines = message?.split('\n') ?? <String>['null'];
  if (wrapWidth != null) {
    _debugPrintBuffer.addAll(!tag.isNullOrBlank
        ? messageLines.expand<String>(
            (String line) => _debugWordWrap("$tag$line", wrapWidth))
        : messageLines
            .expand<String>((String line) => _debugWordWrap(line, wrapWidth)));
  } else {
    _debugPrintBuffer.addAll(messageLines);
  }
  if (!_debugPrintScheduled) _debugPrintTask();
}

int _debugPrintedCharacters = 0;
const int _kDebugPrintCapacity = 12 * 1024;
const Duration _kDebugPrintPauseTime = Duration(seconds: 1);
final Queue<String> _debugPrintBuffer = Queue<String>();
final Stopwatch _debugPrintStopwatch = Stopwatch();
Completer<void>? _debugPrintCompleter;
bool _debugPrintScheduled = false;

void _debugPrintTask() {
  _debugPrintScheduled = false;
  if (_debugPrintStopwatch.elapsed > _kDebugPrintPauseTime) {
    _debugPrintStopwatch.stop();
    _debugPrintStopwatch.reset();
    _debugPrintedCharacters = 0;
  }
  while (_debugPrintedCharacters < _kDebugPrintCapacity &&
      _debugPrintBuffer.isNotEmpty) {
    final String line = _debugPrintBuffer.removeFirst();
    _debugPrintedCharacters +=
        line.length; // TODO(ianh): Use the UTF-8 byte length instead
    print(line);
  }
  if (_debugPrintBuffer.isNotEmpty) {
    _debugPrintScheduled = true;
    _debugPrintedCharacters = 0;
    Timer(_kDebugPrintPauseTime, _debugPrintTask);
    _debugPrintCompleter ??= Completer<void>();
  } else {
    _debugPrintStopwatch.start();
    _debugPrintCompleter?.complete();
    _debugPrintCompleter = null;
  }
}

/// A Future that resolves when there is no longer any buffered content being
/// printed by [debugPrintThrottled] (which is the default implementation for
/// [debugPrint], which is used to report errors to the console).
Future<void> get debugPrintDone =>
    _debugPrintCompleter?.future ?? Future<void>.value();

final RegExp _indentPattern = RegExp('^ *(?:[-+*] |[0-9]+[.):] )?');
enum _WordWrapParseMode { inSpace, inWord, atBreak }

/// Wraps the given string at the given width.
///
/// Wrapping occurs at space characters (U+0020). Lines that start with an
/// octothorpe ("#", U+0023) are not wrapped (so for example, Dart stack traces
/// won't be wrapped).
///
/// Subsequent lines attempt to duplicate the indentation of the first line, for
/// example if the first line starts with multiple spaces. In addition, if a
/// `wrapIndent` argument is provided, each line after the first is prefixed by
/// that string.
///
/// This is not suitable for use with arbitrary Unicode text. For example, it
/// doesn't implement UAX #14, can't handle ideographic text, doesn't hyphenate,
/// and so forth. It is only intended for formatting error messages.
///
/// The default [debugPrint] implementation uses this for its line wrapping.
Iterable<String> _debugWordWrap(String message, int width,
    {String wrapIndent = ''}) sync* {
  if (message.length < width || message.trimLeft()[0] == '#') {
    yield message;
    return;
  }
  final Match prefixMatch = _indentPattern.matchAsPrefix(message)!;
  final String prefix = wrapIndent + ' ' * prefixMatch.group(0)!.length;
  int start = 0;
  int startForLengthCalculations = 0;
  bool addPrefix = false;
  int index = prefix.length;
  _WordWrapParseMode mode = _WordWrapParseMode.inSpace;
  late int lastWordStart;
  int? lastWordEnd;
  while (true) {
    switch (mode) {
      case _WordWrapParseMode
          .inSpace: // at start of break point (or start of line); can't break until next break
        while ((index < message.length) && (message[index] == ' ')) index += 1;
        lastWordStart = index;
        mode = _WordWrapParseMode.inWord;
        break;
      case _WordWrapParseMode.inWord: // looking for a good break point
        while ((index < message.length) && (message[index] != ' ')) index += 1;
        mode = _WordWrapParseMode.atBreak;
        break;
      case _WordWrapParseMode.atBreak: // at start of break point
        if ((index - startForLengthCalculations > width) ||
            (index == message.length)) {
          // we are over the width line, so break
          if ((index - startForLengthCalculations <= width) ||
              (lastWordEnd == null)) {
            // we should use this point, because either it doesn't actually go over the
            // end (last line), or it does, but there was no earlier break point
            lastWordEnd = index;
          }
          if (addPrefix) {
            yield prefix + message.substring(start, lastWordEnd);
          } else {
            yield message.substring(start, lastWordEnd);
            addPrefix = true;
          }
          if (lastWordEnd >= message.length) return;
          // just yielded a line
          if (lastWordEnd == index) {
            // we broke at current position
            // eat all the spaces, then set our start point
            while ((index < message.length) && (message[index] == ' '))
              index += 1;
            start = index;
            mode = _WordWrapParseMode.inWord;
          } else {
            // we broke at the previous break point, and we're at the start of a new one
            assert(lastWordStart > lastWordEnd);
            start = lastWordStart;
            mode = _WordWrapParseMode.atBreak;
          }
          startForLengthCalculations = start - prefix.length;
          assert(addPrefix);
          lastWordEnd = null;
        } else {
          // save this break point, we're not yet over the line width
          lastWordEnd = index;
          // skip to the end of this break point
          mode = _WordWrapParseMode.inSpace;
        }
        break;
    }
  }
}
