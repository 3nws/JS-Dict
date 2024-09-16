import "package:flutter/material.dart";
import "package:jsdict/packages/copy.dart";
import "package:jsdict/packages/image_search/model.enum.dart";
import "package:jsdict/packages/navigation.dart";
import "package:jsdict/providers/query_provider.dart";

void showOCRResultDialog(BuildContext context, Model model, String text,
        {StackTrace? stackTrace}) =>
    showDialog(
        context: context, builder: (context) => OCRResultDialog(model, text));

class OCRResultDialog extends StatelessWidget {
  const OCRResultDialog(this.model, this.text, {super.key});

  final Model model;
  final String text;

  void _copyResult(BuildContext context) {
    copyText(context, text, name: "OCR result");

    popAll(context);
  }

  void _searchResult(BuildContext context) {
    final queryProvider = QueryProvider.of(context);
    queryProvider.query = text;

    popAll(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding:
          const EdgeInsets.only(top: 28, bottom: 12, left: 28, right: 28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28),
      title:
          Text("${model.title} result", style: const TextStyle(fontSize: 20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              text,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => _searchResult(context),
            child: const Text("Search")),
        TextButton(
          child: const Text("Copy"),
          onPressed: () => _copyResult(context),
        ),
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
