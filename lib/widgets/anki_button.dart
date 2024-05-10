import "package:async/async.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/singletons.dart";

class AnkiButton extends StatelessWidget {
  final Word? word;
  final Kanji? kanji;
  const AnkiButton({super.key, this.kanji, this.word});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          final anki = getAnki();
          final version = await anki.apiHostSpecVersion();
          if (version.isError) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        "You haven't given permission to write to AnkiDroid or the API isn't available. Is AnkiDroid installed?")),
              );
            }
            return;
          }
          final decks = await anki.deckList();
          if (decks.isValue) {
            Result<int> res;

            // Add the deck if it doesn't exist
            final decksMap = decks.asValue!.value;
            int deckId = (decksMap.keys.firstWhere(
                (k) => decksMap[k] == "JS-Dict",
                orElse: () => -1)) as int;
            if (deckId == -1) {
              res = await anki.addNewDeck("JS-Dict");
              if (res.isValue) {
                deckId = res.asValue!.value;
              }
            }

            // Add the model if it doesn't exist
            final models = await anki.getModelList(0);
            if (models.isValue) {
              final modelsMap = models.asValue!.value;
              int modelId = (modelsMap.keys.firstWhere(
                  (k) =>
                      modelsMap[k] ==
                      "js-dict-${kanji != null ? 'kanji' : 'word'}",
                  orElse: () => -1)) as int;

              final AnkiModel model =
                  kanji != null ? AnkiKanjiModel() : AnkiWordModel();

              if (modelId == -1) {
                res = await anki.addNewCustomModel(model.name, model.fields,
                    model.cards, model.qfmt, model.afmt, model.css, null, null);
                if (res.isValue) {
                  modelId = res.asValue!.value;
                }
              }
              final fields = kanji != null
                  ? [
                      kanji!.kanji,
                      kanji!.kunReadings.join(", "),
                      kanji!.onReadings.join(", "),
                      kanji!.meanings.join(", "),
                      "https://jisho.org/search/${kanji!.kanji}"
                    ]
                  : [
                      word!.word.getText(),
                      word!.word.getReading(),
                      word!.definitions.join(", "),
                      word!.definitions
                          .map((definition) => definition.exampleSentence)
                          .mapIndexed((idx, sentence) {
                            return sentence == null
                                ? null
                                : "${idx + 1}. ${sentence.japanese.map((part) => "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '</b>' : ''}").join()}";
                          })
                          .toList()
                          .whereType<String>()
                          .join("\n\n"),
                      word!.definitions
                          .map((definition) => definition.exampleSentence)
                          .mapIndexed((idx, sentence) {
                            return sentence == null
                                ? null
                                : "${idx + 1}. ${sentence.japanese.map((part) => "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '[${part.furigana}]' : ''}${part.furigana != '' ? '</b>' : ''}").join()}";
                          })
                          .toList()
                          .whereType<String>()
                          .join("\n\n"),
                      word!.definitions
                          .map((definition) => definition.exampleSentence)
                          .mapIndexed((idx, sentence) {
                            return sentence == null
                                ? null
                                : "${idx + 1}. ${sentence.english}\n";
                          })
                          .toList()
                          .whereType<String>()
                          .join("\n\n"),
                      "https://jisho.org/word/${word!.id}"
                    ];

              // Finally add or update the note
              final dups = await anki.findDuplicateNotesWithKey(
                  modelId, kanji != null ? kanji!.kanji : word!.word.getText());
              if (dups.isValue) {
                final dupsList = dups.asValue!.value;
                final ourDups = dupsList.where((dup) => (dup["tags"] as List)
                    .contains("${kanji != null ? 'kanji' : 'word'}_js-dict"));
                if (ourDups.isNotEmpty) {
                  ourDups.toList().forEach((dup) {
                    anki.updateNoteFields(dup["id"] as int, fields).then((res) {
                      if (res.isValue) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "${kanji != null ? 'Kanji' : 'Word'} updated in JS-Dict deck.")),
                        );
                      }
                    });
                  });
                } else {
                  anki.addNote(modelId, deckId, fields, [
                    "${kanji != null ? 'kanji' : 'word'}_js-dict"
                  ]).then((res) {
                    if (res.isValue) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "${kanji != null ? 'Kanji' : 'Word'} added to JS-Dict deck.")),
                      );
                    }
                  });
                }
              }
            }
          }
          anki.killIsolate();
        },
        icon: SvgPicture.asset(
          "assets/anki-icon.svg",
          semanticsLabel: "AnkiDroid Logo",
        ));
  }
}
