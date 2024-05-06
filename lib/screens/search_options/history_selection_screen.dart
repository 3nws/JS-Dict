import "package:flutter/material.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/search_options/search_options_screen.dart";

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

    return SingleChildScrollView(
        child: Column(
      children: [
        ListTile(
          title: const Text("Recent searches"),
          trailing: GestureDetector(
            onTap: () {
              queryProvider.clearHistory();
              setState(() {});
            },
            child: const Text(
              "CLEAR",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...queryProvider.history.map((historyEntry) => ListTile(
            title: Text(historyEntry),
            trailing: const Icon(Icons.north_west),
            onTap: () => queryProvider.query = historyEntry))
      ],
    ));
  }
}