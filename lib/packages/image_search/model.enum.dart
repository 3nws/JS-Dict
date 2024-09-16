enum Model { vertical, horizontal }

extension ModelExtension on Model {
  String get code {
    switch (this) {
      case Model.vertical:
        return "jpn_vert";
      default:
        return "jpn";
    }
  }

  String get title {
    switch (this) {
      case Model.vertical:
        return "Vertical Model";
      default:
        return "Horizontal Model";
    }
  }
}
