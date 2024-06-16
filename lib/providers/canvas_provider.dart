import "package:flutter/material.dart";
import "package:jsdict/singletons.dart";
import "package:provider/provider.dart";

class CanvasProvider extends ChangeNotifier {
  static CanvasProvider of(BuildContext context) {
    return Provider.of<CanvasProvider>(context, listen: false);
  }

  String currentStroke = "";
  List<Offset> currentLine = [];
  List<List<Offset>> lines = [];
  List<List<double>> pressures = [];
  List<double> currentLinePressures = [];
  
  List<String> strokes = [];
  List<String> matchingKanji = [];

  String _sexp = "";
  String get sexp => _sexp;

  double width = 0;
  double height = 0;

  set sexp(String text) {
    _sexp = text;
    update();
  }

  void reset() {
    pressures = [];
    currentLine = [];
    lines = [];
    currentLinePressures = [];
    strokes = [];
    matchingKanji = [];
    sexp = "";
    notifyListeners();
  }

  void update() {
    getClient().handwritingMatches(sexp).then((kanjis) {
      matchingKanji = kanjis;
      notifyListeners();
    });
  }

  void back() {
    (pressures.isNotEmpty) ? pressures.removeLast() : null;
    (currentLine.isNotEmpty) ? currentLine.removeLast() : null;
    (lines.isNotEmpty) ? lines.removeLast() : null;
    (currentLinePressures.isNotEmpty)
        ? currentLinePressures.removeLast()
        : null;
    (strokes.isNotEmpty) ? strokes.removeLast() : null;
    sexp =
        "(character (width $width) (height $height) (strokes ${strokes.join()}))";
    update();
  }
}
