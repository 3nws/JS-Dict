import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:jsdict/providers/theme_provider.dart";
import "package:provider/provider.dart";

class InfoChip extends StatelessWidget {
  const InfoChip(this.text, {super.key, this.color, this.onTap});

  final String text;
  final Color? color;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (dynamicColorScheme, _) => Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final dynamicColorsDisabled = dynamicColorScheme == null || !themeProvider.dynamicColors;
            return Card(
              surfaceTintColor: dynamicColorsDisabled ? color : null,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48)),
              child: InkWell(
                borderRadius: BorderRadius.circular(48),
                onTap: onTap,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(text),
                ),
              ));
          }
            ),
    );
  }
}

class InfoChipList extends StatelessWidget {
  InfoChipList(this.entries, {super.key}) : coloredEntries = [];
  InfoChipList.color(this.coloredEntries, {super.key}) : entries = [];

  final List<String> entries;
  final List<(String, Color?)> coloredEntries;

  @override
  Widget build(BuildContext context) {
    final children = coloredEntries.isNotEmpty
        ? coloredEntries
            .map((entry) => InfoChip(entry.$1, color: entry.$2))
            .toList()
        : entries.map((entry) => InfoChip(entry)).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      children: children,
    );
  }
}
