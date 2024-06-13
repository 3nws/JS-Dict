import "package:flutter/material.dart";
import "package:jsdict/jp_text.dart";

class CustomKanjiButton extends StatelessWidget {
  const CustomKanjiButton(this.text,
      {super.key,
      this.onPressed,
      this.textStyle,
      this.backgroundColor,
      this.padding = 0})
      : iconData = null,
        iconColor = null,
        iconSize = 0;

  const CustomKanjiButton.icon(
    this.iconData, {
    super.key,
    this.onPressed,
    this.iconSize = 16,
    this.iconColor,
  })  : text = "",
        textStyle = null,
        backgroundColor = null,
        padding = 0;

  final Function()? onPressed;
  final Color? backgroundColor;
  final double size = 32;
  final double padding;

  final String text;
  final TextStyle? textStyle;

  final IconData? iconData;
  final double iconSize;
  final Color? iconColor;

  double get _size => size - (padding * 2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          fixedSize: Size(_size, _size),
          minimumSize: const Size(0, 0),
        ),
        child: iconData != null
            ? Icon(iconData, size: iconSize, color: iconColor)
            : JpText(text, style: textStyle),
      ),
    );
  }
}
