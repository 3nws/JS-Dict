import "dart:ui";
import "package:flutter/material.dart";
import "package:jsdict/providers/canvas_provider.dart";
import "package:provider/provider.dart";

class Writeable extends StatefulWidget {
  const Writeable({super.key});

  @override
  State<Writeable> createState() => _WriteableState();
}

class _WriteableState extends State<Writeable> {
  late double pressure;
  late Offset position;
  String currentStroke = "";

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Consumer<CanvasProvider>(builder: (_, provider, __) {
      return Listener(
        onPointerMove: (details) {
          final int x = details.localPosition.dx.toInt();
          final int y = details.localPosition.dy.toInt();
          final String stroke = "($x $y)";
          setState(() {
            provider.currentLinePressures.add(details.pressure);
            provider.currentLine.add(details.localPosition);
            currentStroke += "$stroke ";
          });
        },
        onPointerUp: (details) {
          setState(() {
            provider.lines.add(provider.currentLine.toList());
            provider.pressures.add(provider.currentLinePressures.toList());
            provider.currentLine.clear();
            provider.currentLinePressures.clear();
            provider.strokes.add("($currentStroke)");
            currentStroke = "";
            provider.sexp =
                "(character (width ${provider.width}) (height ${provider.height}) (strokes ${provider.strokes.join()}))";
          });
        },
        child: LayoutBuilder(builder: (context, constraints) {
          provider.width = constraints.maxWidth;
          provider.height = constraints.maxHeight;
          return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: Painter(
                    repaint: provider,
                    lines: provider.lines,
                    currentLine: provider.currentLine,
                    pressures: provider.pressures,
                    currentLinePressures: provider.currentLinePressures,
                    color: primaryColor),
              ));
        }),
      );
    });
  }
}

class Painter extends CustomPainter {
  Painter(
      {required this.repaint,
      required this.lines,
      required this.currentLine,
      required this.color,
      required this.pressures,
      required this.currentLinePressures})
      : super(repaint: repaint);

  final Listenable repaint;
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final Color color;
  final List<List<double>> pressures;
  final List<double> currentLinePressures;

  double scalePressures = 10;
  Paint paintStyle = Paint();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintStyle.color = color;
    for (int i = 0; i < currentLine.length - 1; i++) {
      paintStyle.strokeWidth = currentLinePressures[i] * scalePressures;
      canvas.drawPoints(
          PointMode.lines, [currentLine[i], currentLine[i + 1]], paintStyle);
    }
    for (int i = 0; i < lines.length; i++) {
      for (int j = 0; j < lines[i].length - 1; j++) {
        paintStyle.strokeWidth = pressures[i][j] * scalePressures;
        canvas.drawPoints(
            PointMode.lines, [lines[i][j], lines[i][j + 1]], paintStyle);
      }
    }
  }
}
