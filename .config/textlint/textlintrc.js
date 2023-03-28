const path = require("path");
const fs = require("fs");

const homePath = process.env.HOME;
const configDirpath = path.join(homePath, ".config/textlint");
const localConfigDirpath = path.join(homePath, ".config/textlint.local");

const { deepmerge } = require(path.join(homePath, ".config/util"));

const fixableConfigPath = path.join(configDirpath, "textlintrc.fixable.js");
const fixableConfig = fs.existsSync(fixableConfigPath)
  ? require(fixableConfigPath)
  : {};

const localConfigPath = path.join(localConfigDirpath, "textlintrc.local.js");
const localConfig = fs.existsSync(localConfigPath)
  ? require(localConfigPath)
  : {};

const config = {
  filters: {
    allowlist: {
      allow: [
        // Ignore "方" because "ja-hiragana-keishikimeishi" shows too many false positives.
        "方",

        // Disable ja-unnatural-alphabet.
        "ｗｗｗ",
      ],
    },
  },
  rules: {
    "@textlint-ja/no-synonyms": true,
    "@textlint-ja/textlint-rule-no-insert-dropping-sa": true,
    "date-weekday-mismatch": { lang: "ja-JP" },
    "ja-hiragana-keishikimeishi": true,

    // Disable because of false positive: too many proper nouns, e.g., people's names, are treated as error.
    "joyo-kanji": false,

    "no-hoso-kinshi-yogo": true,
    "prefer-tari-tari": {
      severity: "warning",
    },
    "preset-ja-technical-writing": {
      // Disable because whether to use Arabic numbers or Kanji numbers depends on the content.
      "arabic-kanji-numbers": false,

      "ja-no-mixed-period": {
        allowPeriodMarks: [":", "、", "ｗ", "👍"],
        allowEmojiAtEnd: true,
      },
      "ja-no-redundant-expression": {
        severity: "warning",
      },

      // Disable because "weak phrases" should be used to express an opinion. Expressing without "weak phrases" causes
      // people misunderstanding as if an opinion was a fact. An opinion should be distinguished from a fact.
      "ja-no-weak-phrase": false,

      "ja-no-successive-word": {
        allow: ["…", "─", "など"],
      },

      // Disable because many commas and "ten"s are sometimes needed and the "sentence-length" rule is available for
      // avoiding too long sentences.
      "max-comma": false,
      "max-ten": false,

      // Disable because a double negative differs from a regular affirmative.
      "no-double-negative-ja": false,

      "no-doubled-conjunction": {
        severity: "warning",
      },
      "no-doubled-joshi": {
        severity: "warning",
        allow: ["か", "とか", "とも", "にも", "も"],
        commaCharacters: [
          "/",
          "“",
          "”",
          "←",
          "→",
          "、",
          "「",
          "」",
          "＆",
          "（",
          "）",
          "，",
        ],
      },

      // Use exclamation marks and question marks.
      "no-exclamation-question-mark": false,

      "sentence-length": {
        severity: "warning",
        max: 200,
        skipPatterns: [
          "/\\bhttps?:\\/\\/[^\\s)>]+/", // URL
          "/\\b[a-z\\d]{7,40}\\b/", // commit hash
          "/\\([^)]+?\\)/", // inside parentheses
          '/"[^"]+?"/', // inside quotation marks
          "/`[^`]+?`/", // inside backticks
          "/（[^）]+?）/", // かっこ内
          "/「[^」]+?」/", // かぎかっこ内
          "/『[^』]+?』/", // 二重かぎかっこ内
          "/“[^”]+?”/", // 引用符内
        ],
      },
    },
    "preset-jtf-style": {
      "1.1.1.本文": false, // 1.1.1: 本文を敬体(ですます調)に統一して下さい。 本文の文体は、敬体(ですます調)あるいは常体(である調)のどちらかで統一します。 → false positive
      "3.1.1.全角文字と半角文字の間": false, // 3.1.1: 原則として、全角文字と半角文字の間にスペースを入れません。 → 入れることがある
      "3.1.2.全角文字どうし": false, // 3.1.2: 原則として、全角文字どうしの間にスペースを入れません。 → 入れることがある
      "3.3.かっこ類と隣接する文字の間のスペースの有無": false, // 3.3:   かっこの外側、内側ともにスペースを入れません。 → 入れることがある
      "4.2.1.感嘆符(！)": false, // 4.2.1: 感嘆符(！)を使用する場合は「全角」で表記します。 → 半角も使う
      "4.2.2.疑問符(？)": false, // 4.2.2: 文末に疑問符を使用し、後に別の文が続く場合は、直後に全角スペースを挿入します。 → 半角スペースが好み
      "4.2.6.ハイフン(-)": false, // 4.2.6: 原則として和文ではハイフン(-)を使用しません。 例外は、住所や電話番号の区切りに使う場合です。 → 使うことがある
      "4.2.7.コロン(：)": false, // 4.2.7: コロン(：)を使用する場合は「全角」で表記します。 → 半角＋スペースが好み
      "4.3.1.丸かっこ（）": false, // 4.3.1: 半角のかっこ()が使用されています。全角のかっこ（）を使用してください。 → 使うことがある
      "4.3.2.大かっこ［］": false, // 4.3.2: 半角の大かっこ[]が使用されています。全角のかっこ［］を使用してください。 → 使うことがある
    },
  },
};

module.exports = deepmerge(deepmerge(config, fixableConfig), localConfig);
