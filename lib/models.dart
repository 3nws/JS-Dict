import 'package:ruby_text/ruby_text.dart';

class SearchResponse {
  bool found;

  String correction = "";
  String suggestion = "";

  List<Word> wordResults = [];
  List<Kanji> kanjiResults = [];
  List<Sentence> sentenceResults = [];
  List<Name> nameResults = [];
  
  SearchResponse(this.found);

  bool hasNoMatches(JishoTag type) {
    switch (type.runtimeType) {
      case Kanji:
        return kanjiResults.isEmpty;
      case Sentence:
        return sentenceResults.isEmpty;
      case Name:
        return nameResults.isEmpty;
      case Word:
        return wordResults.isEmpty;
    }

    throw Exception("Unknown type");
  }
}

abstract class JishoTag {
  /* Returns the Jisho tag corresponding to the type, without the # */
  String getTag();
}

enum JLPTLevel implements JishoTag {
  n1, n2, n3, n4, n5, none;

  @override
  String toString() {
    switch (this) {
      case n1: return "N1";
      case n2: return "N2";
      case n3: return "N3";
      case n4: return "N4";
      case n5: return "N5";
      default: return "";
    }
  }

  static JLPTLevel fromString(final String level) {
    switch (level.toLowerCase()) {
      case "n1": return n1;
      case "n2": return n2;
      case "n3": return n3;
      case "n4": return n4;
      case "n5": return n5;
      default: return none;
    }
  }

  static JLPTLevel findInText(final String text) {
    final pattern = RegExp(r"JLPT (N\d)");
    final match = pattern.firstMatch(text.toUpperCase());
    if (match == null) return none;
    return fromString(match.group(1)!);
  }

  @override
  String getTag() {
    return "jlpt-${toString().toLowerCase()}";
  }
}

class Radical {
  final String character;
  final List<String> meanings;
  
  Radical(this.character, this.meanings);
  
  Radical.empty()
    : character = "",
      meanings = [];
}

class ReadingCompound {
  final String compound;
  final String reading;
  final List<String> meanings;

  ReadingCompound(this.compound, this.reading, this.meanings);
}

class Kanji implements JishoTag {
  final String kanji;
  
  List<String> meanings = [];
  List<String> kunReadings = [];
  List<String> onReadings = [];
  
  int strokeCount = -1;
  int grade = -1;
  JLPTLevel jlptLevel = JLPTLevel.none;

  List<String>? parts;
  List<String>? variants;
  
  Radical radical = Radical.empty();
  
  int? frequency;

  List<ReadingCompound> onReadingCompounds = [];
  List<ReadingCompound> kunReadingCompounds = [];
  
  Kanji(this.kanji);
  Kanji.empty() : kanji = "";

  @override
  String getTag() {
    return "kanji";
  }
}

class OtherForm {
  final String form;
  final String reading;
  
  OtherForm(this.form, this.reading);

  @override
  String toString() {
    if (reading.isEmpty) {
      return form;
    }
    return "$form ($reading)";
  }
}

enum DefinitionType {
  noun, nounNo,
  adjectiveNa, adjectiveI,
  verbIchidan, verbSuru,
  verbRu, verbNu, verbMu, verbKu, verbSu, verbYuku,
  verbTrans, verbIntrans, verbAux,
  adverb, adverbTo,
  expression, prefix, suffix,
  wikipedia
}

class Definition {
  List<String> meanings = [];
  List<String> types = [];

  @override
  String toString() {
    return meanings.join(", ");
  }
}

class Word implements JishoTag {
  final Furigana word;
  List<Definition> definitions = [];
  List<OtherForm> otherForms = [];

  /// `true` if the word has the "Common word" tag.
  bool commonWord = false;
  /// WaniKani level, between `1` and `60`. Set to `-1` if not applicable.
  int wanikaniLevel = -1;
  /// JLPT level of the word.
  JLPTLevel jlptLevel = JLPTLevel.none;

  /// URL to an audio file. Empty string if there is none.
  String audioUrl = "";

  /// Word notes
  String notes = "";

  // Kanji in the word
  List<Kanji>? wordKanji;

  Word(this.word);
  Word.empty() : word = [];

  @override
  String getTag() {
    return "words";
  }
}

class FuriganaPart {
  final String text;
  final String furigana;
  FuriganaPart(this.text, this.furigana);
  FuriganaPart.textOnly(this.text) : furigana = "";
}

typedef Furigana = List<FuriganaPart>;

extension FuriganaMethods on List<FuriganaPart> {
  String getText() {
    return map((part) => part.text.trim()).join().trim();
  }

  String getReading() {
    return map((part) => part.furigana.isNotEmpty ? part.furigana : part.text).join().trim();
  }

  List<RubyTextData> toRubyData() {
    return map((part) => part.furigana.isEmpty ? RubyTextData(part.text) : RubyTextData(part.text, ruby: part.furigana)).toList();
  }
}

class SentenceCopyright {
  final String name;
  final String url;
  SentenceCopyright(this.name, this.url);
}

class Sentence implements JishoTag {
  final String id;
  final Furigana japanese;
  final String english;
  final SentenceCopyright? copyright;

  List<Kanji> kanji = [];

  Sentence(this.id, this.japanese, this.english) : copyright = null;
  Sentence.copyright(this.id, this.japanese, this.english, this.copyright);
  Sentence.empty() : id = "", japanese = [], english = "", copyright = null;

  @override
  String getTag() {
    return "sentences";
  }
}

class Name implements JishoTag {
  final String reading;
  final List<String> meanings;

  Name(this.reading, this.meanings);
  Name.empty(): reading = "", meanings = [];

  @override
  String getTag() {
    return "names";
  }
}