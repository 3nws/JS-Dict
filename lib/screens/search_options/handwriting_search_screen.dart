import "package:flutter/material.dart";
import "package:jsdict/providers/canvas_provider.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/search_options/search_options_screen.dart";
import "package:jsdict/widgets/custom_kanji_button.dart";
import "package:jsdict/widgets/hand_writing_canvas.dart";
import "package:provider/provider.dart";

class HandwritingSearchScreen extends SearchOptionsScreen {
  final void Function()? back;
  HandwritingSearchScreen({super.key, this.back})
      : super(
          body: const _HandwritingSearch(),
          floatingActionButton: FloatingActionButton(
            onPressed: back,
            tooltip: "Back",
            heroTag: "back",
            child: const Icon(Icons.undo),
          ),
        );
}

class _HandwritingSearch extends StatelessWidget {
  const _HandwritingSearch();

  @override
  Widget build(BuildContext context) {
    final queryProvider = QueryProvider.of(context);
    final canvasProvider = CanvasProvider.of(context);

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _KanjiSelection(
            onSelect: (kanji) {
              canvasProvider.reset();
              queryProvider.insertText(kanji);
            },
          ),
        ),
        const Divider(height: 0),
        const Expanded(
          flex: 3,
          child: Center(child: HandWritingCanvas()),
        ),
      ],
    );
  }
}

class _KanjiSelection extends StatelessWidget {
  const _KanjiSelection({required this.onSelect});

  final Function(String) onSelect;

  static const displayLimit = 100;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Consumer<CanvasProvider>(
        builder: (_, provider, __) => provider.matchingKanji.isEmpty
            ? const Center(child: Text("Select kanji"))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: [
                        CustomKanjiButton.icon(Icons.refresh,
                            iconSize: 20, iconColor: textColor, onPressed: () {
                          provider.reset();
                        }),
                        ...provider.matchingKanji
                            .take(displayLimit)
                            .map((kanji) => CustomKanjiButton(
                                  kanji,
                                  onPressed: () => onSelect(kanji),
                                  backgroundColor: backgroundColor,
                                  textStyle:
                                      TextStyle(fontSize: 20, color: textColor),
                                  padding: 1.5,
                                )),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
