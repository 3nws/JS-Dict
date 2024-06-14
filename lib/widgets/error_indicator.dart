import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart";
import "package:jsdict/packages/jisho_client/jisho_client.dart";

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator(this.error, {super.key, this.stackTrace, this.onRetry});

  final Object error;
  final Function()? onRetry;
  final StackTrace? stackTrace;

  String get _userMessage {
    if (error is NotFoundException) {
      return "Page not found";
    }

    if (error is SocketException || error is ClientException) {
      return "A network error occured.\nCheck your connection.";
    }

    return "An error occured";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_userMessage, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              child: const Text("Show Error"),
              onPressed: () =>
                  showErrorInfoDialog(context, error, stackTrace: stackTrace),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 4),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showErrorInfoDialog(BuildContext context, Object error,
        {StackTrace? stackTrace}) =>
    showDialog(
        context: context,
        builder: (context) => ErrorInfoDialog(error, stackTrace: stackTrace));

class ErrorInfoDialog extends StatelessWidget {
  const ErrorInfoDialog(this.error, {super.key, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  String get _errorType => error.runtimeType.toString();
  String get _errorMessage => error.toString();

  Widget _infoText(String title, String info, {TextStyle? style}) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
              text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: info),
        ],
      ),
    );
  }

  void _copyError(BuildContext context) {
    final copyText =
        "Type: $_errorType  \nMessage: $_errorMessage  \nStack trace:\n```\n${stackTrace.toString()}```";

    Clipboard.setData(ClipboardData(text: copyText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied error info")),
      );
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding:
          const EdgeInsets.only(top: 28, bottom: 12, left: 28, right: 28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28),
      title: const Text("Error Info", style: TextStyle(fontSize: 20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoText("Type: ", _errorType),
            _infoText("Message: ", _errorMessage),
            if (stackTrace != null) ...[
              _infoText("Stack trace: ", ""),
              _ExpandableText(
                stackTrace.toString(),
                expandText: "Show",
                collapseText: "Hide",
                maxLines: 1,
                linkColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Copy"),
          onPressed: () => _copyError(context),
        ),
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final String expandText;
  final String collapseText;
  final int maxLines;
  final Color linkColor;

  const _ExpandableText(
    this.text, {
    required this.expandText,
    required this.collapseText,
    required this.maxLines,
    required this.linkColor,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  String get text => widget.text;
  String get expandText => widget.expandText;
  String get collapseText => widget.collapseText;
  int get maxLines => widget.maxLines;
  Color get linkColor => widget.linkColor;

  int? _maxLines;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _maxLines ?? maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _maxLines = !_expanded ? 999 : maxLines;
              _expanded = !_expanded;
            });
          },
          child: Text(
            !_expanded ? expandText : collapseText,
            style: TextStyle(color: linkColor),
          ),
        ),
      ],
    );
  }
}
