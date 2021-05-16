import 'package:dbgen/ext/ext.dart';
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
  final size = MediaQuery.of(context).size;
  expanded.d();
  size.d();
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
  final pair = useProvider(tableCartFloatProvider);
  final keys = pair.item1;
  final count = pair.item2;
  final themeData = Theme.of(context);
  return count == 0
      ? SizedBox()
      : InkWell(
          onTap: () {
            context.read(tableCartExpandedProvider).state = true;
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: themeData.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2.0,
                )
              ],
            ),
            width: 48.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var value in keys)
                  Container(
                    width: 32.0,
                    height: 32.0,
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
                  ),
                sizedBoxH8,
                Text(
                  "+${count}",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: monoFont,
                    color: themeData.primaryColor,
                  ),
                )
              ],
            ),
          ),
        );
}

@hwidget
Widget expandedCountTitle() {
  final pair = useProvider(tableCartFloatProvider);
  final count = pair.item2;
  return Text(
    "已选：+${count}",
    style: TextStyle(
      fontSize: 16.0,
      height: 1.25,
      fontWeight: FontWeight.w500,
    ),
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
