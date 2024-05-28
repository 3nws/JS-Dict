import "package:flutter/material.dart";
import "package:jsdict/jp_text.dart";
import "package:jsdict/packages/copy.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/providers/query_provider.dart";

import "item_card.dart";

class ExtractedTextItem extends StatelessWidget {
  const ExtractedTextItem({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final queryProvider = QueryProvider.of(context);
    return ItemCard(
        onTap: () {
          queryProvider.addToHistoryAndSearch(text);
          popAll(context);
        },
        onLongPress: () {
          copyText(context, text);
          popAll(context);
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22.0),
          title: Text(
            text,
            style: jpTextStyle,
          ),
        ));
  }
}
