import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:jsdict/packages/is_kanji.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/kanji_details/kanji_details_screen.dart";

class ProcessTextIntentHandler {
  final BuildContext context;
  final TabController tabController;

  ProcessTextIntentHandler(this.context, this.tabController) {
    const platform = MethodChannel("io.github.petlyh.jsdict");

    platform.invokeMethod("getIntent").then((intentMap) {
      if (intentMap != null &&
          intentMap["action"] == "android.intent.action.PROCESS_TEXT") {
        final String incomingText = intentMap["text"] as String;

        if (!context.mounted) {
          return;
        }

        tabController.index = 0;
        QueryProvider.of(context).query = incomingText;
        popAll(context);

        if (incomingText.length == 1 && isKanji(incomingText)) {
          pushScreen(context, KanjiDetailsScreen.id(incomingText)).call();
        }
      }
    });
  }
}
