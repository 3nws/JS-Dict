import "package:expansion_tile_card/expansion_tile_card.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter/widgets.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:gif/gif.dart";
import "package:jsdict/packages/kanji_diagram/kanji_diagram.dart";
import "package:jsdict/providers/theme_provider.dart";
import "package:jsdict/widgets/loader.dart";
import "package:provider/provider.dart";

class StrokeOrderWidget extends StatefulWidget {
  const StrokeOrderWidget(this.kanjiCode, this.kanjiGifFilename, {super.key});

  final String kanjiCode;
  final String kanjiGifFilename;

  @override
  State<StrokeOrderWidget> createState() => _StrokeOrderWidgetState();
}

class _StrokeOrderWidgetState extends State<StrokeOrderWidget>
    with TickerProviderStateMixin {
  late GifController _controller;
  int _fps = 30;

  @override
  void initState() {
    _controller = GifController(vsync: this);
    super.initState();
  }

  Future<String> getData() async {
    try {
      return await rootBundle
          .loadString("assets/kanjivg/data/${widget.kanjiCode}.svg");
    } on FlutterError {
      // asset not found means that KanjiVg doesn't have data for the kanji
      return "";
    }
  }

  Future<ByteData> getStrokeGIF() async {
    try {
      return await NetworkAssetBundle(Uri.parse(
              "https://raw.githubusercontent.com/mistval/kanji_images/master/gifs/${widget.kanjiGifFilename}.gif"))
          .load("");
    } on FlutterError {
      return ByteData(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
        onLoad: getData,
        handler: (data) {
          if (data.isEmpty) {
            return const SizedBox();
          }
          return ExpansionTileCard(
            shadowColor: Theme.of(context).colorScheme.shadow,
            title: const Text("Stroke Order"),
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: BrightnessBuilder(builder: (context, brightness) {
                    return SvgPicture.string(
                        KanjiDiagram(darkTheme: brightness == Brightness.dark)
                            .create(data),
                        height: 90);
                  })),
              LoaderWidget(
                  onLoad: getStrokeGIF,
                  handler: (data) {
                    return (data.lengthInBytes != 0)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Gif(
                                image: MemoryImage(data.buffer.asUint8List()),
                                controller: _controller,
                                fps: _fps,
                                autostart: Autostart.loop,
                                onFetchCompleted: () {
                                  _controller.reset();
                                  _controller.forward();
                                },
                              ),
                              RotatedBox(
                                quarterTurns: -1,
                                child: Slider(
                                    label: _fps.toString(),
                                    value: _fps.toDouble(),
                                    min: 1,
                                    max: 60,
                                    onChanged: (v) {
                                      setState(() {
                                        _fps = v.round();
                                      });
                                    }),
                              )
                            ],
                          )
                        : const SizedBox.shrink();
                  })
            ],
          );
        });
  }
}

/// Builder that provides the current [Brightness] value of the app.
///
/// Rebuilds itself when [ThemeProvider] is modified and when the
/// platform brightness is changed if [ThemeMode.system] is selected.
class BrightnessBuilder extends StatelessWidget {
  const BrightnessBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, Brightness brightness) builder;

  Brightness getBrightness(BuildContext context, ThemeMode themeMode) {
    if (themeMode == ThemeMode.system) {
      return Theme.of(context).brightness;
    }

    return themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
      return MediaQuery(
          data: const MediaQueryData(),
          child: Builder(
              builder: (context) => builder(context,
                  getBrightness(context, themeProvider.currentTheme))));
    });
  }
}
