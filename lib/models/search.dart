part of "models.dart";

class SearchResponse<T> {
  String correction = "";
  String suggestion = "";
  List<String> noMatchesFor = [];

  bool hasNextPage = false;

  List<T> results = [];

  void addResults(List<dynamic> list) {
    if (list is List<T>) {
      results.addAll(list);
    }
  }
}