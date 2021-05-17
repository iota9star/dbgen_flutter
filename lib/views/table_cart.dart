import 'package:dbgen/ext/ext.dart';
import 'package:dbgen/misc/transition.dart';
import 'package:dbgen/providers.dart';
import 'package:dbgen/topvars.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'table_cart.g.dart';

const kDefaultCartBottomOffset = 64.0;

@hwidget
Widget tableCart(BuildContext context) {
  final expanded = useProvider(tableCartExpandedProvider).state;
  return expanded
      ? AnimatedPositioned(
          child: const ExpandedTableCart(),
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          duration: const Duration(milliseconds: 300),
        )
      : AnimatedPositioned(
          child: const FloatCart(),
          bottom: 64.0,
          right: 0,
          duration: const Duration(milliseconds: 300),
        );
}

@hwidget
Widget floatCart(BuildContext context) {
  final selected = useProvider(selectedTableProvider);
  final count = selected.length;
  final themeData = Theme.of(context);
  return count == 0
      ? SizedBox()
      : InkWell(
          onTap: () {
            context.read(tableCartExpandedProvider).state = true;
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: themeData.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2.0,
                )
              ],
            ),
            width: 40.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FloatCartSelectedSource(),
                sizedBoxH4,
                const FloatCartCount(),
              ],
            ),
          ),
        );
}

@hwidget
Widget floatCartSelectedSource() {
  final keys = useProvider(tableCartFloatKeysProvider);
  return ListView.builder(
    itemBuilder: (_, index) {
      final value = keys.elementAt(index);
      return Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          color: value.color,
        ),
        child: Center(
            child: Text(
          value.title.characters.first,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            height: 1.25,
            color: value.color.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
          ),
        )),
      );
    },
    itemCount: keys.length,
    shrinkWrap: true,
  );
}

@hwidget
Widget floatCartCount(BuildContext context) {
  final pair = useProvider(tableCartFloatCountNotifierProvider);
  final themeData = Theme.of(context);
  var prev = pair.item1.toString();
  var next = pair.item2.toString();
  if (prev.length > next.length) {
    next = next.fillChar(prev, " ");
  } else if (prev.length < next.length) {
    prev = prev.fillChar(next, " ");
  }
  final children = List.generate(prev.length, (ind) {
    final newChar = next[ind];
    final oldChar = prev[ind];
    final key = ValueKey(newChar);
    final up = (int.tryParse(newChar) ?? 0) - (int.tryParse(oldChar) ?? 0) >= 0;
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 256 + ind * 64),
      transitionBuilder: (child, animation) {
        return counterTransitionBuilder(
          key,
          up,
          child,
          animation,
        );
      },
      child: Text(
        newChar,
        key: key,
        style: TextStyle(
          fontFamily: monoFont,
          fontSize: 11.0,
          color: themeData.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  });
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [...children],
  );
}

@hwidget
Widget expandedCountTitle() {
  final selected = useProvider(selectedTableProvider);
  final count = selected.length;
  final countKey = ValueKey(count);
  return Row(
    children: [
      Text("已选：+"),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return counterTransitionBuilder(countKey, true, child, animation);
        },
        child: Text(
          count.toString(),
          key: countKey,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: "mono",
          ),
        ),
      )
    ],
  );
}

@hwidget
Widget expandedTableCart(BuildContext context) {
  final themeData = Theme.of(context);
  return Container(
    decoration: BoxDecoration(
      color: themeData.scaffoldBackgroundColor.withOpacity(0.87),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [const TableCartItems()],
    ),
  );
}

@hwidget
Widget tableCartItems(BuildContext context) {
  final themeData = Theme.of(context);
  final grouped = useProvider(tableCartProvider);
  if (grouped.length == 1) {
    final first = grouped.entries.first.value.entries.first;
    return Container(
      width: 300.0,
      height: double.infinity,
      decoration: BoxDecoration(
        color: themeData.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2.0,
          )
        ],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPinnedToBoxAdapter(
            child: Container(
              color: themeData.backgroundColor,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(FluentIcons.chevron_down_24_regular),
                    onPressed: () {
                      context.read(tableCartExpandedProvider).state = false;
                    },
                  ),
                  const ExpandedCountTitle(),
                ],
              ),
            ),
          ),
          SliverPinnedToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              color: themeData.backgroundColor,
              child: Text(
                first.key,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SliverAnimatedList(
            itemBuilder: (_, index, animation) {
              final item = first.value[index];
              return ProviderScope(
                overrides: [tableCartItemProvider.overrideWithValue(item)],
                child: const TableCartItem(),
              );
            },
            initialItemCount: first.value.length,
          ),
        ],
      ),
    );
  }
  return Container();
}

@hwidget
Widget tableCartItem() {
  final item = useProvider(tableCartItemProvider);
  return ListTile(
    title: Text(
      item.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        height: 1.25,
        fontFamily: monoFont,
      ),
    ),
    subtitle: Text(
      item.comment.isNullOrBlank ? "暂无备注" : item.comment!,
      style: TextStyle(
        fontSize: 12.0,
        height: 1.25,
      ),
    ),
  );
}
