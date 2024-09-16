import "package:flutter/material.dart";
import "package:jsdict/jp_text.dart";
import "package:jsdict/packages/image_search/model.enum.dart";
import "package:jsdict/widgets/ocr_result_dialog.dart";

import "item_card.dart";

class ExtractedTextItem extends StatelessWidget {
  const ExtractedTextItem({super.key, required this.model, required this.text});

  final Model model;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
        onTap: () {
          showOCRResultDialog(context, model, text);
        },
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22.0),
          title: Text(model.title),
          subtitle: Text(
            text,
            style: jpTextStyle,
          ),
        ));
  }
}
