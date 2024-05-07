import "dart:ui";
import "package:flutter/material.dart";
import "package:jsdict/providers/canvas_provider.dart";

class Writeable extends StatefulWidget {
  const Writeable({super.key});

  @override
  State<Writeable> createState() => _WriteableState();
}

class _WriteableState extends State<Writeable> {
  late double pressure;
  late Offset position;
  late Painter painter;
  late CustomPaint paintCanvas;
  String currentStroke = "";

  @override
  Widget build(BuildContext context) {
    final canvasProvider = CanvasProvider.of(context);

    painter = Painter(
        lines: canvasProvider.lines,
        currentLine: canvasProvider.currentLine,
        pressures: canvasProvider.pressures,
        currentLinePressures: canvasProvider.currentLinePressures,
        color: canvasProvider.color);

    paintCanvas = CustomPaint(
      painter: painter,
    );

    return Listener(
      onPointerMove: (details) {
        final int x = details.localPosition.dx.toInt();
        final int y = details.localPosition.dy.toInt();
        final String stroke = "($x $y)";
        setState(() {
          canvasProvider.currentLinePressures.add(details.pressure);
          canvasProvider.currentLine.add(details.localPosition);
          currentStroke += "$stroke ";
        });
      },
      onPointerUp: (details) {
        setState(() {
          canvasProvider.lines.add(canvasProvider.currentLine.toList());
          canvasProvider.pressures
              .add(canvasProvider.currentLinePressures.toList());
          canvasProvider.currentLine.clear();
          canvasProvider.currentLinePressures.clear();
          canvasProvider.strokes.add("($currentStroke)");
          currentStroke = "";
          canvasProvider.sexp =
              "(character (width ${canvasProvider.width}) (height ${canvasProvider.height}) (strokes ${canvasProvider.strokes.join()}))";
        });
      },
      child: LayoutBuilder(builder: (context, constraints) {
        canvasProvider.width = constraints.maxWidth;
        canvasProvider.height = constraints.maxHeight;
        return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: paintCanvas);
      }),
    );
  }
}

class Painter extends CustomPainter {
  Painter(
      {required this.lines,
      required this.currentLine,
      required this.color,
      required this.pressures,
      required this.currentLinePressures});

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
