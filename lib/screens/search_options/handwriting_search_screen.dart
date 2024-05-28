import "package:flutter/material.dart";
import "package:jsdict/jp_text.dart";
import "package:jsdict/providers/canvas_provider.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/search_options/search_options_screen.dart";
import "package:jsdict/widgets/writeable.dart";
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

class _HandwritingSearch extends StatefulWidget {
  const _HandwritingSearch();

  @override
  State<_HandwritingSearch> createState() => _HandwritingSearchState();
}

class _HandwritingSearchState extends State<_HandwritingSearch> {
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
          child: Center(child: Writeable()),
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
    final backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;

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
                        _CustomButton.icon(Icons.refresh,
                            iconSize: 20, iconColor: textColor, onPressed: () {
                          provider.reset();
                        }),
                        ...provider.matchingKanji
                            .take(displayLimit)
                            .map((kanji) => _CustomButton(
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

class _CustomButton extends StatelessWidget {
  const _CustomButton(this.text,
      {this.onPressed, this.textStyle, this.backgroundColor, this.padding = 0})
      : iconData = null,
        iconColor = null,
        iconSize = 0;

  const _CustomButton.icon(
    this.iconData, {
    this.onPressed,
    this.iconSize = 16,
    this.iconColor,
  })  : text = "",
        textStyle = null,
        backgroundColor = null,
        padding = 0;

  final Function()? onPressed;
  final Color? backgroundColor;
  final double size = 32;
  final double padding;

  final String text;
  final TextStyle? textStyle;

  final IconData? iconData;
  final double iconSize;
  final Color? iconColor;

  double get _size => size - (padding * 2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          fixedSize: Size(_size, _size),
          minimumSize: const Size(0, 0),
        ),
        child: iconData != null
            ? Icon(iconData, size: iconSize, color: iconColor)
            : JpText(text, style: textStyle),
      ),
    );
  }
}
