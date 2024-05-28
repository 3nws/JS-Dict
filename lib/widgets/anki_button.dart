import "package:async/async.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:flutter_ankidroid/flutter_ankidroid.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/packages/string_util.dart";
import "package:jsdict/singletons.dart";

class AnkiButton extends StatelessWidget {
  final Word? word;
  final Kanji? kanji;
  final Sentence? sentence;
  const AnkiButton({super.key, this.kanji, this.word, this.sentence});

  Future<int?> getDeckId(Ankidroid anki) async {
    final decks = await anki.deckList();
    if (decks.isValue) {
      Result<int> res;

      // Add the deck if it doesn't exist
      final decksMap = decks.asValue!.value;
      int deckId = (decksMap.keys.firstWhere((k) => decksMap[k] == "JS-Dict",
          orElse: () => -1)) as int;
      if (deckId == -1) {
        res = await anki.addNewDeck("JS-Dict");
        if (res.isValue) {
          deckId = res.asValue!.value;
        }
      }
      return deckId;
    }
    return null;
  }

  Future<int?> getModelId(Ankidroid anki, String type) async {
    final models = await anki.getModelList(0);
    if (models.isValue) {
      Result<int> res;
      final modelsMap = models.asValue!.value;
      int modelId = (modelsMap.keys.firstWhere(
          (k) => modelsMap[k] == "js-dict-$type",
          orElse: () => -1)) as int;

      AnkiModel model;

      switch (type) {
        case "kanji":
          model = AnkiKanjiModel();
          break;
        case "word":
          model = AnkiWordModel();
          break;
        case "sentence":
          model = AnkiSentenceModel();
          break;
        default:
          return null;
      }

      if (modelId == -1) {
        res = await anki.addNewCustomModel(model.name, model.fields,
            model.cards, model.qfmt, model.afmt, model.css, null, null);
        if (res.isValue) {
          modelId = res.asValue!.value;
        }
      }
      return modelId;
    }
    return null;
  }

  Future<List<String>?> getFieldsByType(String type) async {
    List<String> fields = [];
    switch (type) {
      case "kanji":
        fields = [
          kanji!.kanji,
          kanji!.kunReadings.join(", "),
          kanji!.onReadings.join(", "),
          kanji!.meanings.join(", "),
          "https://jisho.org/search/${kanji!.kanji}"
        ];
        break;
      case "word":
        fields = [
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
              .join("<br><br>"),
          word!.definitions
              .map((definition) => definition.exampleSentence)
              .mapIndexed((idx, sentence) {
                return sentence == null
                    ? null
                    : "${idx + 1}. ${sentence.japanese.map((part) => "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '[${part.furigana}]' : ''}${part.furigana != '' ? '</b>' : ''}").join()}";
              })
              .toList()
              .whereType<String>()
              .join("<br><br>"),
          word!.definitions
              .map((definition) => definition.exampleSentence)
              .mapIndexed((idx, sentence) {
                return sentence == null
                    ? null
                    : "${idx + 1}. ${sentence.english}";
              })
              .toList()
              .whereType<String>()
              .join("<br><br>"),
          word!.audioUrl == null
              ? ""
              : "<audio controls src='${word!.audioUrl}'></audio>",
          "https://jisho.org/word/${word!.id}"
        ];
        break;
      case "sentence":
        final List<Kanji> sentenceKanji = sentence!.kanji ??
            (await getClient().search<Kanji>(sentence!.japanese.getText()))
                .results;
        fields = [
          sentence!.japanese.getText(),
          (sentence!.japanese
              .map((part) =>
                  "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '[${part.furigana}]' : ''}${part.furigana != '' ? '</b>' : ''}")
              .join()),
          sentence!.english,
          sentenceKanji
              .map((kanji) =>
                  "<a href='https://jisho.org/search/${kanji.kanji}' class='kanji'><b>${kanji.kanji}</b></a>\n\n<br><br>")
              .join(),
          "https://jisho.org/sentences/${sentence!.id}"
        ];
        break;
      default:
        return null;
    }
    return fields;
  }

  String? getKeyByType(String type) {
    String key;
    switch (type) {
      case "kanji":
        key = kanji!.kanji;
        break;
      case "word":
        key = word!.word.getText();
        break;
      case "sentence":
        key = sentence!.japanese.getText();
        break;
      default:
        return null;
    }
    return key;
  }

  void updateNote(Ankidroid anki, Iterable<dynamic> ourDups,
      List<String> fields, String type, BuildContext context) {
    ourDups.toList().forEach((dup) {
      anki.updateNoteFields(dup["id"] as int, fields).then((res) {
        if (res.isValue) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text("${type.capitalize()} updated in the JS-Dict deck.")),
          );
        }
      });
    });
  }

  void addNote(Ankidroid anki, List<String> fields, int modelId, int deckId,
      String type, BuildContext context) {
    anki.addNote(modelId, deckId, fields, ["${type}_js-dict"]).then((res) {
      if (res.isValue) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${type.capitalize()} added to the JS-Dict deck.")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          final anki = getAnki();
          final version = await anki.apiHostSpecVersion();
          final object = kanji ?? word ?? sentence;
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

          String type;
          if (object is Kanji) {
            type = "kanji";
          } else if (object is Word) {
            type = "word";
          } else if (object is Sentence) {
            type = "sentence";
          } else {
            return;
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Please wait while the ${type.capitalize()} is being added to the JS-Dict deck.")),
            );
          }

          final decks = await anki.deckList();
          if (!decks.isValue) return;

          final int? deckId = await getDeckId(anki);
          final int? modelId = await getModelId(anki, type);
          final List<String>? fields = await getFieldsByType(type);
          final String? key = getKeyByType(type);
          if ([deckId, modelId, fields, key].contains(null)) return;

          final dups = await anki.findDuplicateNotesWithKey(modelId!, key!);
          if (dups.isValue && context.mounted) {
            final dupsList = dups.asValue!.value;
            final ourDups = dupsList.where(
                (dup) => (dup["tags"] as List).contains("${type}_js-dict"));
            if (ourDups.isNotEmpty) {
              updateNote(anki, ourDups, fields!, type, context);
            } else {
              addNote(anki, fields!, modelId, deckId!, type, context);
            }
          }
        },
        icon: SvgPicture.asset(
          "assets/anki-icon.svg",
          semanticsLabel: "AnkiDroid Logo",
        ));
  }
}
