import "package:flutter/material.dart";
import "package:jsdict/packages/remove_tags.dart";
import "package:jsdict/singletons.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

class QueryProvider extends ChangeNotifier {
  final SharedPreferences _preferences = getPreferences();
  static QueryProvider of(BuildContext context) {
    return Provider.of<QueryProvider>(context, listen: false);
  }

  TextEditingController searchController = TextEditingController();

  String _query = "";
  String get query => _query;

  set query(String text) {
    searchController.text = text;
    updateQuery();
  }

  void sanitizeText() {
    searchController.text = removeTypeTags(searchController.text)
        .trim()
        .replaceAll(RegExp(r"\s+"), " ");
  }

  void updateQuery() {
    sanitizeText();
    _query = searchController.text;
    addToHistory(searchController.text);
    notifyListeners();
  }

  void updateQueryIfChanged() {
    if (_query != searchController.text) {
      updateQuery();
    }
  }

  void addTag(String tag) {
    sanitizeText();
    if (searchController.text.isNotEmpty) {
      searchController.text += " ";
    }
    searchController.text += "#$tag";
  }

  void clearTags() {
    searchController.text = removeTags(searchController.text);
    sanitizeText();
  }

  void insertText(String text) {
    final selection = searchController.selection;
    final selectionStart = selection.baseOffset;

    if (selectionStart == -1) {
      searchController.text += text;
      return;
    }

    final newText = searchController.text
        .replaceRange(selectionStart, selection.extentOffset, text);
    searchController.text = newText;
    searchController.selection =
        TextSelection.collapsed(offset: selectionStart + 1);
  }

  static const _historyKey = "History";
  List<String> get history => _preferences.getStringList(_historyKey) ?? [];

  void addToHistory(String text) {
    if (text.isNotEmpty) {
      _preferences.setStringList(
          _historyKey,
          history
            ..remove(text)
            ..insert(0, text));
      getHistorySync().sendQuery(text);
    }
  }

  void syncHistory() {
    getHistorySync().sendHistory(history);
  }

  void removeFromHistory(String query) {
    _preferences.setStringList(_historyKey, history..remove(query));
    notifyListeners();
  }

  void clearHistory() {
    _preferences.remove(_historyKey);
    searchController.text = "";
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
