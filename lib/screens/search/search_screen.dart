import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image_picker/image_picker.dart";
import "package:jsdict/jp_text.dart";
import "package:jsdict/models/models.dart";
import "package:jsdict/packages/image_search/image_search.dart";
import "package:jsdict/packages/link_handler.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/packages/process_text_intent_handler.dart";
import "package:jsdict/packages/share_intent_handler.dart";
import "package:jsdict/providers/canvas_provider.dart";
import "package:jsdict/providers/query_provider.dart";
import "package:jsdict/screens/search/result_page.dart";
import "package:jsdict/screens/search_options/handwriting_search_screen.dart";
import "package:jsdict/screens/search_options/history_selection_screen.dart";
import "package:jsdict/screens/search_options/radical_search_screen.dart";
import "package:jsdict/screens/search_options/tag_selection_screen.dart";
import "package:jsdict/screens/settings_screen.dart";
import "package:provider/provider.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const placeholder =
      Center(child: Text("JS-Dict", style: TextStyle(fontSize: 32.0)));

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LinkHandler _linkHandler;
  late ShareIntentHandler _shareIntentHandler;
  late FocusNode _searchFocusNode;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _linkHandler = LinkHandler(context, _tabController);
    _shareIntentHandler = ShareIntentHandler(context, _tabController);
    ProcessTextIntentHandler(context, _tabController);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _linkHandler.dispose();
    _shareIntentHandler.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryProvider = QueryProvider.of(context);
    final searchController = queryProvider.searchController;
    final canvasProvider = CanvasProvider.of(context);

    final List<Widget> ocrFlavorWidgets = appFlavor == "ocr"
        ? [
            FloatingActionButton(
              onPressed: () =>
                  ImageSearch.pickImage(context, ImageSource.gallery),
              tooltip: "Image Search",
              heroTag: "imagesearch",
              child: const Icon(Icons.image),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: () =>
                  ImageSearch.pickImage(context, ImageSource.camera),
              tooltip: "Camera Search",
              heroTag: "camerasearch",
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(
              height: 10,
            )
          ]
        : [];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ...ocrFlavorWidgets,
            FloatingActionButton(
              onPressed: pushScreen(
                  context, HandwritingSearchScreen(back: canvasProvider.back)),
              tooltip: "Handwriting",
              heroTag: "handwriting",
              child: const Icon(Icons.draw_outlined),
            ),
            const SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              onPressed: pushScreen(context, const RadicalSearchScreen()),
              tooltip: "Radicals",
              heroTag: "radicals",
              child: const Text("部", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: TextField(
          style: jpTextStyle,
          focusNode: _searchFocusNode,
          controller: searchController,
          onSubmitted: (text) => queryProvider.addToHistoryAndSearch(text),
          autofocus: false,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              hintText: "Search...",
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchFocusNode.requestFocus();
                  searchController.clear();
                },
                tooltip: "Clear",
              )),
        ),
        actions: [
          IconButton(
            onPressed: pushScreen(context, const TagSelectionScreen()),
            icon: const Icon(Icons.tag),
            tooltip: "Tags",
          ),
          IconButton(
            onPressed: pushScreen(context, const HistorySelectionScreen()),
            icon: const Icon(Icons.history),
            tooltip: "History",
          ),
          IconButton(
            onPressed: pushScreen(context, const SettingScreen()),
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
        bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(text: "Words"),
              Tab(text: "Kanji"),
              Tab(text: "Names"),
              Tab(text: "Sentences"),
            ]),
      ),
      body: Consumer<QueryProvider>(
        builder: (_, provider, __) => provider.query.isEmpty
            ? SearchScreen.placeholder
            : TabBarView(controller: _tabController, children: [
                ResultPage<Word>(provider.query, key: UniqueKey()),
                ResultPage<Kanji>(provider.query, key: UniqueKey()),
                ResultPage<Name>(provider.query, key: UniqueKey()),
                ResultPage<Sentence>(provider.query, key: UniqueKey()),
              ]),
      ),
    );
  }
}
