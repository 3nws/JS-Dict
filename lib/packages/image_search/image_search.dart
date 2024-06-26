import "package:flutter/material.dart";
import "package:flutter_tesseract_ocr/android_ios.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:jsdict/widgets/items/extracted_text_item.dart";

class ImageSearch {
  static Future<void> pickImage(
      BuildContext context, ImageSource source) async {
    final XFile? image =
        await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (!context.mounted || image == null) return;
    final String? imagePath =
        await cropImage(Theme.of(context).colorScheme, image.path);
    if (!context.mounted || imagePath == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Processing... Please wait."),
        duration: Duration(minutes: 2),
      ),
    );
    final List<List<String>> models = [
      ["jpn_vert", "jpn"],
      ["Vertical model", "Horizontal model"]
    ];
    final List<String>? texts = await processImage(models[0], imagePath);
    if (texts == null && context.mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No matches."),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final List<ExtractedTextItem> items = [];
    if (texts != null) {
      for (final (idx, text) in texts.indexed) {
        items.add(ExtractedTextItem(model: models[1][idx], text: text));
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

  static Future<String?> cropImage(
      ColorScheme colorScheme, String imagePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Cropper",
            backgroundColor: colorScheme.surface,
            toolbarColor: colorScheme.surface,
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white,
            toolbarWidgetColor: colorScheme.primary,
            activeControlsWidgetColor: colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );
    return croppedFile?.path;
  }

  static Future<List<String>?> processImage(
      List<String> models, String imagePath) async {
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
