import "package:expansion_tile_card/expansion_tile_card.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:jsdict/packages/kanji_diagram/kanji_diagram.dart";
import "package:jsdict/providers/theme_provider.dart";
import "package:jsdict/widgets/loader.dart";
import "package:path_drawing/path_drawing.dart";
import "package:provider/provider.dart";
import "package:xml/xml.dart";

class StrokeOrderWidget extends StatefulWidget {
  const StrokeOrderWidget(this.kanjiCode, this.kanjiGifFilename, {super.key});

  final String kanjiCode;
  final String kanjiGifFilename;

  @override
  State<StrokeOrderWidget> createState() => _StrokeOrderWidgetState();
}

class _StrokeOrderWidgetState extends State<StrokeOrderWidget>
    with SingleTickerProviderStateMixin {
  Future<String> getData() async {
    try {
      return await rootBundle
          .loadString("assets/kanjivg/data/${widget.kanjiCode}.svg");
    } on FlutterError {
      // asset not found means that KanjiVg doesn't have data for the kanji
      return "";
    }
  }

  late List<String> paths;
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String cleanPath(XmlElement path) {
    path.removeAttribute("id");
    path.removeAttribute("kvg:type");
    return path.attributes.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
        onLoad: getData,
        handler: (data) {
          if (data.isEmpty) {
            return const SizedBox();
          }
          paths = XmlDocument.parse(data)
              .descendantElements
              .where((element) => element.name.local == "path")
              .map(cleanPath)
              .toList();
          _animations = List.generate(paths.length, (index) {
            return Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index / paths.length,
                  (index + 1) / paths.length,
                  curve: Curves.easeInOut,
                ),
              ),
            );
          });
          _controller.repeat();

          return ExpansionTileCard(
            initiallyExpanded: true,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.topLeft,
                    child: AbsorbPointer(
                      child: CustomPaint(
                        painter: AnimatedPathsPainter(
                            paths: paths,
                            animations: _animations,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
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

class AnimatedPathsPainter extends CustomPainter {
  final List<String> paths;
  final List<Animation<double>> animations;
  final Color color;

  AnimatedPathsPainter(
      {required this.paths, required this.animations, required this.color})
      : super(repaint: animations[animations.length - 1]);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    for (int i = 0; i < paths.length; i++) {
      final path = Path();
      path.addPath(
          parseSvgPathData(paths[i]), Offset(size.width / 2, size.height / 2));
      final progress = animations[i].value;
      final currentPath = extractPath(path, progress);
      canvas.drawPath(currentPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Path extractPath(Path originalPath, double lengthPercentage) {
    final totalLength = originalPath.computeMetrics().single.length;
    final currentLength = totalLength * lengthPercentage;
    final metric = originalPath.computeMetrics().single;
    return metric.extractPath(0, currentLength);
  }
}
