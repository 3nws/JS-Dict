const wordTags = {
  "Dialects": {
    "Hokkaido": "hob",
    "Kansai": "ksb",
    "Kantou": "ktb",
    "Kyoto": "kyb",
    "Kyuushuu": "kyu",
    "Nagano": "nab",
    "Osaka": "osb",
    "Ryuukyuu": "rkb",
    "Touhoku": "thb",
    "Tosa": "tsb",
    "Tsugaru": "tsug",
  },
  "JLPT": {
    "JLPT N1": "jlpt-n1",
    "JLPT N2": "jlpt-n2",
    "JLPT N3": "jlpt-n3",
    "JLPT N4": "jlpt-n4",
    "JLPT N5": "jlpt-n5",
  },
  "Names": {
    "Family or surname": "surname",
    "Place": "place",
    "Unclassified name": "unclass",
    "Company": "company",
    "Product": "product",
    "Male given name": "masc",
    "Female given name": "fem",
    "Full name": "person",
    "Given name, gender not specified": "given",
    "Train station": "station",
    "Organization": "organization",
    "Old or irregular kana form": "oik",
  },
  "Topics": {
    "Agriculture": "agric",
    "Anatomy": "anat",
    "Archeology": "archeol",
    "Architecture": "archit",
    "Art, aesthetics": "art",
    "Astronomy": "astron",
    "Audiovisual": "audvid",
    "Aviation": "aviat",
    "Baseball": "baseb",
    "Biochemistry": "biochem",
    "Biology": "biol",
    "Botany": "bot",
    "Buddhism": "Buddh",
    "Business": "bus",
    "Chemistry": "chem",
    "Christianity": "Christn",
    "Clothing": "cloth",
    "Computing": "comp",
    "Crystallography": "cryst",
    "Ecology": "ecol",
    "Economics": "econ",
    "Electricity, elec. eng.": "elec",
    "Electronics": "electr",
    "Embryology": "embryo",
    "Engineering": "engr",
    "Entomology": "ent",
    "Finance": "finc",
    "Fishing": "fish",
    "Food, cooking": "food",
    "Gardening, horticulture": "gardn",
    "Genetics": "genet",
    "Geography": "geogr",
    "Geology": "geol",
    "Geometry": "geom",
    "Go (game)": "go",
    "Golf": "golf",
    "Grammar": "gramm",
    "Greek mythology": "grmyth",
    "Hanafuda": "hanaf",
    "Horse racing": "horse",
    "Law": "law",
    "Linguistics": "ling",
    "Logic": "logic",
    "Martial arts": "MA",
    "Mahjong": "mahj",
    "Mathematics": "math",
    "Mechanical engineering": "mech",
    "Medicine": "med",
    "Meteorology": "met",
    "Military": "mil",
    "Music": "music",
    "Ornithology": "ornith",
    "Paleontology": "paleo",
    "Pathology": "pathol",
    "Pharmacy": "pharm",
    "Philosophy": "phil",
    "Photography": "photo",
    "Physics": "physics",
    "Physiology": "physiol",
    "Printing": "print",
    "Psychiatry": "psy",
    "Psychology": "psych",
    "Railway": "rail",
    "Shinto": "Shinto",
    "Shogi": "shogi",
    "Sports": "sports",
    "Statistics": "stat",
    "Sumo": "sumo",
    "Telecommunications": "telec",
    "Trademark": "tradem",
    "Video games": "vidg",
    "Zoology": "zool",
  },
  "Other": {
    "Verb of any type": "verb",
    "Adjective of any type": "adjective",
    "Counter words": "counter",
    "Brazilian": "bra",
    "Ateji (phonetic) reading": "ateji",
    "Irregular kana usage": "ik",
    "Irregular kanji usage": "iK",
    "Irregular okurigana usage": "io",
    "Out-dated kanji or kanji usage": "oK",
    "Rarely-used kanji form": "rK",
    "Abbreviation": "abbr",
    "Archaism": "arch",
    "Character": "char",
    "Children's language": "chn",
    "Colloquialism": "col",
    "Company name": "company",
    "Creature": "creat",
    "Dated term": "dated",
    "Deity": "dei",
    "Derogatory": "derog",
    "Document": "doc",
    "Event": "ev",
    "Familiar language": "fam",
    "Female term or language": "fem",
    "Fiction": "fict",
    "Formal or literary term": "form",
    "Given name or forename, gender not specified": "given",
    "Group": "group",
    "Historical term": "hist",
    "Honorific or respectful (sonkeigo) language": "hon",
    "Humble (kenjougo) language": "hum",
    "Idiomatic expression": "id",
    "Jocular, humorous term": "joc",
    "Legend": "leg",
    "Manga slang": "m-sl",
    "Male term or language": "male",
    "Mythology": "myth",
    "Internet slang": "net-sl",
    "Object": "obj",
    "Obsolete term": "obs",
    "Obscure term": "obsc",
    "Onomatopoeic or mimetic word": "on-mim",
    "Organization name": "organization",
    "Other": "oth",
    "Full name of a particular person": "person",
    "Place name": "place",
    "Poetical term": "poet",
    "Polite (teineigo) language": "pol",
    "Product name": "product",
    "Proverb": "proverb",
    "Quotation": "quote",
    "Rare": "rare",
    "Religion": "relig",
    "Sensitive": "sens",
    "Service": "serv",
    "Slang": "sl",
    "Railway station": "station",
    "Family or surname": "surname",
    "Usually written using kana alone": "uk",
    "Unclassified name": "unclass",
    "Vulgar expression or word": "vulg",
    "Work of art, literature, music, etc. name": "work",
    "Rude or X-rated term": "X",
    "Yojijukugo (four character compound)": "yoji",
    "Noun or verb acting prenominally": "adj-f",
    "I-adjective (keiyoushi)": "adj-i",
    "I-Adjective (keiyoushi) - yoi/ii class": "adj-ix",
    "'kari' adjective (archaic)": "adj-kari",
    "'ku' adjective (archaic)": "adj-ku",
    "Na-adjective (keiyodoshi)": "adj-na",
    "Archaic/formal form of na-adjective": "adj-nari",
    "Noun which may take the genitive case particle 'no'": "adj-no",
    "Pre-noun adjectival (rentaishi)": "adj-pn",
    "'shiku' adjective (archaic)": "adj-shiku",
    "'taru' adjective": "adj-t",
    "Adverb (fukushi)": "adv",
    "Adverb taking the 'to' particle": "adv-to",
    "Auxiliary": "aux",
    "Auxiliary adjective": "aux-adj",
    "Auxiliary verb": "aux-v",
    "Conjunction": "conj",
    "Copula": "cop",
    "Counter": "ctr",
    "Expressions (phrases, clauses, etc.)": "exp",
    "Interjection (kandoushi)": "int",
    "Noun": "n",
    "Adverbial noun (fukushitekimeishi)": "n-adv",
    "Proper noun": "n-pr",
    "Noun, used as a prefix": "n-pref",
    "Noun, used as a suffix": "n-suf",
    "Noun (temporal) (jisoumeishi)": "n-t",
    "Numeric": "num",
    "Pronoun": "pn",
    "Prefix": "pref",
    "Particle": "prt",
    "Suffix": "suf",
    "Unclassified": "unc",
    "Verb unspecified": "v-unspec",
    "Ichidan verb": "v1",
    "Ichidan verb - kureru special class": "v1-s",
    "Nidan verb with u ending (archaic)": "v2a-s",
    "Nidan verb (upper class) with bu ending (archaic)": "v2b-k",
    "Nidan verb (lower class) with bu ending (archaic)": "v2b-s",
    "Nidan verb (upper class) with dzu ending (archaic)": "v2d-k",
    "Nidan verb (lower class) with dzu ending (archaic)": "v2d-s",
    "Nidan verb (upper class) with gu ending (archaic)": "v2g-k",
    "Nidan verb (lower class) with gu ending (archaic)": "v2g-s",
    "Nidan verb (upper class) with hu/fu ending (archaic)": "v2h-k",
    "Nidan verb (lower class) with hu/fu ending (archaic)": "v2h-s",
    "Nidan verb (upper class) with ku ending (archaic)": "v2k-k",
    "Nidan verb (lower class) with ku ending (archaic)": "v2k-s",
    "Nidan verb (upper class) with mu ending (archaic)": "v2m-k",
    "Nidan verb (lower class) with mu ending (archaic)": "v2m-s",
    "Nidan verb (lower class) with nu ending (archaic)": "v2n-s",
    "Nidan verb (upper class) with ru ending (archaic)": "v2r-k",
    "Nidan verb (lower class) with ru ending (archaic)": "v2r-s",
    "Nidan verb (lower class) with su ending (archaic)": "v2s-s",
    "Nidan verb (upper class) with tsu ending (archaic)": "v2t-k",
    "Nidan verb (lower class) with tsu ending (archaic)": "v2t-s",
    "Nidan verb (lower class) with u ending and we conjugation (archaic)": "v2w-s",
    "Nidan verb (upper class) with yu ending (archaic)": "v2y-k",
    "Nidan verb (lower class) with yu ending (archaic)": "v2y-s",
    "Nidan verb (lower class) with zu ending (archaic)": "v2z-s",
    "Yodan verb with bu ending (archaic)": "v4b",
    "Yodan verb with gu ending (archaic)": "v4g",
    "Yodan verb with hu/fu ending (archaic)": "v4h",
    "Yodan verb with ku ending (archaic)": "v4k",
    "Yodan verb with mu ending (archaic)": "v4m",
    "Yodan verb with nu ending (archaic)": "v4n",
    "Yodan verb with ru ending (archaic)": "v4r",
    "Yodan verb with su ending (archaic)": "v4s",
    "Yodan verb with tsu ending (archaic)": "v4t",
    "Godan verb - -aru special class": "v5aru",
    "Godan verb with bu ending": "v5b",
    "Godan verb with gu ending": "v5g",
    "Godan verb with ku ending": "v5k",
    "Godan verb - Iku/Yuku special class": "v5k-s",
    "Godan verb with mu ending": "v5m",
    "Godan verb with nu ending": "v5n",
    "Godan verb with ru ending": "v5r",
    "Godan verb with ru ending (irregular verb)": "v5r-i",
    "Godan verb with su ending": "v5s",
    "Godan verb with tsu ending": "v5t",
    "Godan verb with u ending": "v5u",
    "Godan verb with u ending (special class)": "v5u-s",
    "Godan verb - Uru old class verb (old form of Eru)": "v5uru",
    "Intransitive verb": "vi",
    "Kuru verb - special class": "vk",
    "Irregular nu verb": "vn",
    "Irregular ru verb, plain form ends with -ri": "vr",
    "Suru verb": "vs",
    "Su verb - precursor to the modern suru": "vs-c",
    "Suru verb - included": "vs-i",
    "Suru verb - special class": "vs-s",
    "Transitive verb": "vt",
    "Ichidan verb - zuru verb (alternative form of -jiru verbs)": "vz",
    "Gikun (meaning as reading) or jukujikun (special kanji reading)": "gikun",
    "Out-dated or obsolete kana usage": "ok",
    "Usually written using kanji alone": "uK",
    "Adjective": "adj",
    "Antonym": "ant",
    "Copula (da)": "cop-da",
    "Equivalent": "equ",
    "Usage example": "ex",
    "Explanatory": "expl",
    "Figuratively": "fig",
    "Irregular verb": "iv",
    "Approved reading for jouyou kanji": "jouyou",
    "Kun reading": "kun",
    "Kanji variant": "kvar",
    "Literaly": "lit",
    "Male slang": "male-sl",
    "Name reading (nanori)": "name",
    "Old or irregular kana form": "oik",
    "Reading used as name of radical": "rad",
    "See also": "see",
    "Synonym": "syn",
    "Godan verb with zu ending": "v5z",
    "Wasei, word made in Japan": "wasei",
    "Literary or formal term": "litf",
  }
};

const nameTags = {
  "surname": "Family or surname",
  "place": "Place",
  "unclass": "Unclassified name",
  "company": "Company",
  "product": "Product",
  "masc": "Male given name",
  "fem": "Female given name",
  "person": "Full name",
  "given": "Given name, gender not specified",
  "station": "Train station",
  "organization": "Organization",
  "oik": "Old or irregular kana form",
};