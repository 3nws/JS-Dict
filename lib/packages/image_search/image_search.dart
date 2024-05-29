import "package:flutter/material.dart";
import "package:flutter_tesseract_ocr/android_ios.dart";
import "package:image_picker/image_picker.dart";
import "package:jsdict/widgets/items/extracted_text_item.dart";

class ImageSearch {
  static Future<void> pickImage(
      BuildContext context, ImageSource source) async {
    final XFile? image =
        await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (!context.mounted || image == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Processing... Please wait."),
        duration: Duration(minutes: 2),
      ),
    );
    final List<String>? texts = await processImage(image.path);
    if (texts == null && context.mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No matches."),
          duration: Duration(seconds: 1),
        ),
      );
    }
    final List<ExtractedTextItem> items = [];
    if (texts != null) {
      for (final text in texts) {
        items.add(ExtractedTextItem(text: text));
      }
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemCount: items.length,
            controller: scrollController,
            itemBuilder: (context, index) => items[index],
            separatorBuilder: (context, index) {
              return const Divider();
            },
          ),
        ),
      ),
    );
  }

  static Future<List<String>?> processImage(String imagePath) async {
    final List<String> models = ["jpn_vert", "jpn"];
    final List<String> texts = [];
    for (final model in models) {
      final String text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: model,
      );
      if (text.isNotEmpty) {
        texts.add(text.replaceAll(" ", ""));
      }
    }
    if (texts.isEmpty) {
      return null;
    }
    return texts;
  }
}
