import "package:flutter/material.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/search_options/search_options_screen.dart";
import "package:jsdict/singletons.dart";
import "package:provider/provider.dart";

class HistorySelectionScreen extends SearchOptionsScreen {
  const HistorySelectionScreen({super.key})
      : super(body: const _HistorySelection());
}

class _HistorySelection extends StatefulWidget {
  const _HistorySelection();

  @override
  State<_HistorySelection> createState() => _HistorySelectionState();
}

class _HistorySelectionState extends State<_HistorySelection> {
  @override
  Widget build(BuildContext context) {
    final queryProvider = QueryProvider.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final List<Widget> syncWidgets =
        getPreferences().getString("syncBulkUrl") != null &&
                queryProvider.history.isNotEmpty
            ? [
                const VerticalDivider(
                  thickness: 3,
                ),
                GestureDetector(
                  onTap: () {
                    queryProvider.syncHistory();
                  },
                  child: Text(
                    "SYNC ALL",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ]
            : [];

    return Consumer<QueryProvider>(builder: (_, provider, __) {
      return SingleChildScrollView(
          child: Column(
        children: [
          ListTile(
            title: const Text("Recent searches"),
            trailing: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      provider.clearHistory();
                    },
                    child: Text(
                      "CLEAR",
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...syncWidgets
                ],
              ),
            ),
          ),
          ...provider.history.map((historyEntry) => ListTile(
              title: Text(historyEntry),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.north_west),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                      onTap: () => provider.removeFromHistory(historyEntry),
                      child: const Icon(Icons.clear)),
                ],
              ),
              onTap: () {
                provider.query = historyEntry;
                popAll(context);
              }))
        ],
      ));
    });
  }
}
