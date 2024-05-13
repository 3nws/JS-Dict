part of "models.dart";

abstract class AnkiModel {
  String get name => "js-dict";
  List<String> get fields => [];
  List<String> get cards => [];
  List<String> get qfmt => [];
  List<String> get afmt => [];
  String get css => "";
}

class AnkiWordModel extends AnkiModel {
  @override
  String name = "js-dict-word";

  @override
  List<String> fields = [
    "Japanese",
    "Reading",
    "Meaning",
    "SentKanji",
    "SentFurigana",
    "SentenceMeaning",
    "Link"
  ];

  @override
  List<String> cards = ["Japanese > English"];

  @override
  List<String> qfmt = ["""<div id="kanji">{{Japanese}}</div>"""];

  @override
  List<String> afmt = [
    """{{FrontSide}}\n\n<hr id=answer>\n\n{{Reading}}\n\n<br><br>{{Meaning}}\n\n<br><br><div class="jpsentence" lang="ja">\n{{edit:furigana:SentFurigana}}\n{{^SentFurigana}}\n{{furigana:SentKanji}}{{/SentFurigana}}</div>\n\n<br><br>{{SentenceMeaning}}<br><br>{{#Link}}<a href="{{Link}}">Open in JS-Dict</a>{{/Link}}""",
  ];

  @override
  String css =
      """#kanji{\n\nfont-size: 35px;text-align: center;}\n\n.card{\n\nfont-family: arial;\n\nfont-size: 20px;\n\ntext-align: center;\n\ncolor: black;\n\nbackground-color: white;\n\n} b { font-weight: 600; } .jpsentence { font-size: 35px; }""";
}

class AnkiKanjiModel extends AnkiModel {
  @override
  String name = "js-dict-kanji";

  @override
  List<String> fields = [
    "Kanji",
    "KunReadings",
    "OnReadings",
    "Meanings",
    "Link"
  ];

  @override
  List<String> cards = ["Kanji"];

  @override
  List<String> qfmt = ["""<div id="kanji">{{Kanji}}</div>"""];

  @override
  List<String> afmt = [
    """{{FrontSide}}\n\n<hr id=answer>\n\nKun: {{KunReadings}}\n\n<br><br>On: {{OnReadings}}\n\n<br><br>Meanings: {{Meanings}}<br><br>{{#Link}}<a href="{{Link}}">Open in JS-Dict</a>{{/Link}}""",
  ];

  @override
  String css =
      """#kanji{\n\nfont-size: 35px;text-align: center;}\n\n.card{\n\nfont-family: arial;\n\nfont-size: 20px;\n\ntext-align: center;\n\ncolor: black;\n\nbackground-color: white;\n\n}""";
}
