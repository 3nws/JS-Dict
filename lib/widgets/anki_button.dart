import "package:android_intent_plus/android_intent.dart";
import "package:app_settings/app_settings.dart";
import "package:async/async.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:flutter_ankidroid/flutter_ankidroid.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/singletons.dart";
import "package:appcheck/appcheck.dart";

class AnkiButton<T extends SearchType> extends StatelessWidget {
  final T item;
  const AnkiButton({super.key, required this.item});

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

  Future<int?> getModelId(Ankidroid anki) async {
    final models = await anki.getModelList(0);
    if (models.isValue) {
      Result<int> res;
      final String modelName = "js-dict-${T.toString().toLowerCase()}";
      final modelsMap = models.asValue!.value;
      int modelId = (modelsMap.keys.firstWhere((k) => modelsMap[k] == modelName,
          orElse: () => -1)) as int;

      AnkiModel model;

      switch (T) {
        case const (Kanji):
          model = AnkiKanjiModel();
          break;
        case const (Word):
          model = AnkiWordModel();
          break;
        case const (Sentence):
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

  Future<List<String>?> getFields() async {
    List<String> fields = [];
    switch (T) {
      case const (Kanji):
        fields = [
          (item as Kanji).kanji,
          (item as Kanji).kunReadings.join(", "),
          (item as Kanji).onReadings.join(", "),
          (item as Kanji).meanings.join(", "),
          "https://jisho.org/search/${(item as Kanji).kanji}"
        ];
        break;
      case const (Word):
        fields = [
          (item as Word).word.getText(),
          (item as Word).word.getReading(),
          (item as Word).definitions.join(", "),
          (item as Word)
              .definitions
              .map((definition) => definition.exampleSentence)
              .mapIndexed((idx, sentence) {
                return sentence == null
                    ? null
                    : "${idx + 1}. ${sentence.japanese.map((part) => "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '</b>' : ''}").join()}";
              })
              .toList()
              .whereType<String>()
              .join("<br><br>"),
          (item as Word)
              .definitions
              .map((definition) => definition.exampleSentence)
              .mapIndexed((idx, sentence) {
                return sentence == null
                    ? null
                    : "${idx + 1}. ${sentence.japanese.map((part) => "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '[${part.furigana}]' : ''}${part.furigana != '' ? '</b>' : ''}").join()}";
              })
              .toList()
              .whereType<String>()
              .join("<br><br>"),
          (item as Word)
              .definitions
              .map((definition) => definition.exampleSentence)
              .mapIndexed((idx, sentence) {
                return sentence == null
                    ? null
                    : "${idx + 1}. ${sentence.english}";
              })
              .toList()
              .whereType<String>()
              .join("<br><br>"),
          (item as Word).audioUrl == null
              ? ""
              : "<audio controls src='${(item as Word).audioUrl}'></audio>",
          "https://jisho.org/word/${(item as Word).id}"
        ];
        break;
      case const (Sentence):
        final List<Kanji> sentenceKanji = (item as Sentence).kanji ??
            (await getClient()
                    .search<Kanji>((item as Sentence).japanese.getText()))
                .results;
        fields = [
          (item as Sentence).japanese.getText(),
          ((item as Sentence)
              .japanese
              .map((part) =>
                  "${part.furigana != '' ? '<b>' : ''}${part.text}${part.furigana != '' ? '[${part.furigana}]' : ''}${part.furigana != '' ? '</b>' : ''}")
              .join()),
          (item as Sentence).english,
          sentenceKanji
              .map((kanji) =>
                  "<a href='https://jisho.org/search/${kanji.kanji}' class='kanji'><b>${kanji.kanji}</b></a>\n\n<br><br>")
              .join(),
          "https://jisho.org/sentences/${(item as Sentence).id}"
        ];
        break;
      default:
        return null;
    }
    return fields;
  }

  String? getKey() {
    String key;
    switch (T) {
      case const (Kanji):
        key = (item as Kanji).kanji;
        break;
      case const (Word):
        key = (item as Word).word.getText();
        break;
      case const (Sentence):
        key = (item as Sentence).japanese.getText();
        break;
      default:
        return null;
    }
    return key;
  }

  void updateNote(Ankidroid anki, Iterable<dynamic> ourDups,
      List<String> fields, BuildContext context) {
    ourDups.toList().forEach((dup) {
      anki.updateNoteFields(dup["id"] as int, fields).then((res) {
        if (res.isValue) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$T updated in the JS-Dict deck.")),
          );
        }
      });
    });
  }

  void addNote(Ankidroid anki, List<String> fields, int modelId, int deckId,
      BuildContext context) {
    anki.addNote(modelId, deckId, fields,
        ["${T.toString().toLowerCase()}_js-dict"]).then((res) {
      if (res.isValue) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$T added to the JS-Dict deck.")),
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
          if (version.isError) {
            String label;
            String message;
            void Function() callback;
            if (!(await AppCheck.isAppInstalled("com.ichi2.anki"))) {
              label = "Install";
              message = "AnkiDroid is not installed!";
              callback = () async {
                const AndroidIntent intent = AndroidIntent(
                    action: "action_view",
                    data:
                        "https://play.google.com/store/apps/details?id=com.ichi2.anki");
                await intent.launch();
              };
            } else if (!(await AppCheck.isAppEnabled("com.ichi2.anki"))) {
              label = "Enable";
              message = "AnkiDroid is disabled!";
              callback = () async {
                const AndroidIntent intent = AndroidIntent(
                  action: "action_application_details_settings",
                  data: "package:com.ichi2.anki",
                );
                await intent.launch();
              };
            } else {
              label = "Settings";
              message =
                  "AnkiDroid API isn't available or you haven't granted permission.";
              callback = () => AppSettings.openAppSettings();
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    action: SnackBarAction(
                      label: label,
                      onPressed: callback,
                    ),
                    content: Text(message)),
              );
            }
            return;
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Please wait while the $T is being added to the JS-Dict deck.")),
            );
          }

          final decks = await anki.deckList();
          if (!decks.isValue) return;

          final int? deckId = await getDeckId(anki);
          final int? modelId = await getModelId(anki);
          final List<String>? fields = await getFields();
          final String? key = getKey();
          if ([deckId, modelId, fields, key].contains(null)) return;

          final dups = await anki.findDuplicateNotesWithKey(modelId!, key!);
          if (dups.isValue && context.mounted) {
            final dupsList = dups.asValue!.value;
            final ourDups = dupsList.where((dup) => (dup["tags"] as List)
                .contains("${T.toString().toLowerCase()}_js-dict"));
            if (ourDups.isNotEmpty) {
              updateNote(anki, ourDups, fields!, context);
            } else {
              addNote(anki, fields!, modelId, deckId!, context);
            }
          }
        },
        icon: SvgPicture.asset(
          "assets/anki-icon-monochrome.svg",
          semanticsLabel: "AnkiDroid Logo",
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary, BlendMode.srcIn),
        ));
  }
}
