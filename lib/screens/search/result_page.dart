import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/singletons.dart";
import "package:jsdict/widgets/error_indicator.dart";
import "package:jsdict/widgets/items/kanji_item.dart";
import "package:jsdict/widgets/items/name_item.dart";
import "package:jsdict/widgets/items/sentence_item.dart";
import "package:jsdict/widgets/items/word_item.dart";
import "package:provider/provider.dart";

class ResultPage<T> extends StatefulWidget {
  const ResultPage(this.query, {super.key});

  final String query;

  @override
  State<ResultPage<T>> createState() => _ResultPageState<T>();
}

class _ResultPageState<T> extends State<ResultPage<T>> with AutomaticKeepAliveClientMixin<ResultPage<T>> {
  @override
  final bool wantKeepAlive = true;

  final PagingController<int, T> _pagingController = PagingController(firstPageKey: 1);

  List<String> noMatchesFor = [];

  ValueNotifier<Correction?> correction = ValueNotifier<Correction?>(null);

  @override
  void initState() {
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    noMatchesFor = [];
    correction.value = null;

    try {
      final response = await getClient().search<T>(widget.query, page: pageKey);

      if (!mounted) return;

      if (response.noMatchesFor.isNotEmpty) {
        noMatchesFor = response.noMatchesFor;
      }

      if (response.correction != null) {
        correction.value = response.correction;
      }

      if (!response.hasNextPage) {
        _pagingController.appendLastPage(response.results);
        return;
      }

      _pagingController.appendPage(response.results, pageKey + 1);
    } catch (error, stackTrace) {
      _pagingController.error = (error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        _correctionInfo(context),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: PagedSliverList<int, T>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<T>(
              itemBuilder: (context, item, index) => _createItem(item),
              firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                (_pagingController.error.$1 as Object),
                stackTrace: (_pagingController.error.$2 as StackTrace),
                onRetry: _pagingController.refresh,
              ),
              noItemsFoundIndicatorBuilder: (context) {
                return Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.all(16),
                  child: Text(
                      noMatchesFor.isNotEmpty
                          ? "No matches for:\n${noMatchesFor.join("\n")}"
                          : "No matches found",
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 1.75),
                    ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }

  Widget _createItem(T item) {
    return switch (T) {
      Word => WordItem(word: item as Word),
      Kanji => KanjiItem(kanji: item as Kanji),
      Sentence => SentenceItem(sentence: item as Sentence),
      Name => NameItem(name: item as Name),
      _ => throw Exception("Unknown type"),
    };
  }

  Widget _correctionInfo(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    final linkColor = Theme.of(context).colorScheme.primary;
    final queryProvider = Provider.of<QueryProvider>(context, listen: false);

    return ValueListenableBuilder(
      valueListenable: correction,
      builder: (context, correctionValue, _) => SliverPadding(
        padding: correctionValue != null
            ? const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12)
            : EdgeInsets.zero,
        sliver: SliverToBoxAdapter(
            child: correctionValue != null
                ? RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: textColor, height: 1.5),
                      children: [
                        const TextSpan(text: "Searched for "),
                        TextSpan(text: correctionValue.searchedFor, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const TextSpan(text: "\n"),
                        const TextSpan(text: "Try searching for "),
                        TextSpan(
                          text: correctionValue.suggestion,
                          style: TextStyle(fontWeight: FontWeight.w600, color: linkColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              queryProvider.searchController.text = correctionValue.suggestion;
                              queryProvider.updateQuery();
                            },
                        ),
                      ],
                    ))
                : null),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}