import "package:flutter/material.dart";
import "package:jsdict/jp_text.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/screens/kanji_details/kanji_details_screen.dart";

import "item_card.dart";

class KanjiItem extends StatelessWidget {
  const KanjiItem({super.key, required this.kanji});

  final Kanji kanji;

  @override
  Widget build(BuildContext context) {
    return ItemCard(
        onTap: pushScreen(context, KanjiDetailsScreen(kanji)),
        child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22.0),
            leading: JpText(kanji.kanji, style: const TextStyle(fontSize: 35)),
            title: Text(kanji.meanings.join(", "),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kanji.kunReadings.isNotEmpty)
                  JpText("Kun: ${kanji.kunReadings.join("、 ")}"),
                if (kanji.onReadings.isNotEmpty)
                  JpText("On: ${kanji.onReadings.join("、 ")}"),
                JpText([
                  "${kanji.strokeCount} strokes",
                  if (kanji.jlptLevel != JLPTLevel.none)
                    "JLPT ${kanji.jlptLevel}",
                  if (kanji.type != null) kanji.type.toString(),
                ].join(", ")),
              ],
            )));
  }
}

class KanjiItemList extends StatelessWidget {
  const KanjiItemList(this.kanjiList, {super.key});

  final List<Kanji> kanjiList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: kanjiList.length,
        itemBuilder: (_, index) => KanjiItem(kanji: kanjiList[index]));
  }
}
