const path = require("path");
const homePath = process.env["HOME"];
const localConfigPath = path.join(homePath, ".textlintrc.local.js")

const fs = require("fs");
const localConfig = fs.existsSync(localConfigPath) ? require(localConfigPath) : {};

// https://qiita.com/riversun/items/60307d58f9b2f461082a
const deepmerge = (object1, object2) => {
  const isObject = (object) => object && typeof object === "object" && !Array.isArray(object);
  const resultObject = Object.assign({}, object1);

  if (isObject(object1) && isObject(object2)) {
    for (const [key, value2] of Object.entries(object2)) {
      const value1 = object1[key];

      if (isObject(value2) && object1.hasOwnProperty(key) && isObject(value1)) {
        resultObject[key] = deepmerge(value1, value2);
      } else {
        Object.assign(resultObject, { [key]: value2 });
      }
    }
  }

  return resultObject;
};

const config = {
  filters: {
    comments: true,
    allowlist: {
      allow: [],
    },
    "node-types": {
      nodeTypes: ["BlockQuote", "Code", "CodeBlock"],
    },
  },
  rules: {
    "@textlint-ja/no-synonyms": true,
    "@textlint-ja/textlint-rule-no-insert-dropping-sa": true,
    "date-weekday-mismatch": { lang: "ja-JP" },
    "ja-hiragana-keishikimeishi": true,

    // Disable because of false positive: too many proper nouns, e.g., people's names, are treated as error
    "joyo-kanji": false,

    "no-hoso-kinshi-yogo": true,
    "prefer-tari-tari": {
      severity: "warning",
    },
    "preset-ja-technical-writing": {
      "arabic-kanji-numbers": false,

      // Disable because of false positive: some emojis even if `allowEmojiAtEnd` option enabled
      "ja-no-mixed-period": false,

      "ja-no-redundant-expression": {
        severity: "warning",
        dictOptions: {
          // dict1: "すること[助詞](不)可能" は冗長な表現です。 "すること[助詞](不)可能" を省き簡潔な表現にすると文章が明瞭になります。
          dict1: { disabled: true },

          // dict2: "すること[助詞]できる" は冗長な表現です。 "すること[助詞]" を省き簡潔な表現にすると文章が明瞭になります。
          dict2: { disabled: true },

          // dict5: "[サ変名詞]を行う" は冗長な表現です。 "[サ変名詞]する" など簡潔な表現にすると文章が明瞭になります。
          dict5: { disabled: true },
        },
      },
      "ja-no-weak-phrase": false,

      // Disable because of false positive: listing items are sometimes treated as error
      "max-ten": false,

      "no-double-negative-ja": {
        severity: "warning",
      },
      "no-doubled-joshi": {
        severity: "warning",
        allow: ["か", "にも", "も"],
        commaCharacters: ["、", "，", "「", "」", "（", "）", "/", "→", "←"],
      },
      "no-exclamation-question-mark": false,
      "sentence-length": {
        severity: "warning",
        max: 100,
        exclusionPatterns: [
          "/\\bhttps?:\\/\\/[^\\s)>]+/",  // URL
          "/\\b[a-z\\d]{40}\\b/",         // commit hash
        ],
      },
    },
    "preset-jtf-style": {
      "1.1.1.本文": false,
      "3.1.1.全角文字と半角文字の間": false,
      "3.1.2.全角文字どうし": false,
      "3.3.かっこ類と隣接する文字の間のスペースの有無": false,
      "4.2.1.感嘆符(！)": false,
      "4.2.2.疑問符(？)": false,
      "4.2.6.ハイフン(-)": false,
      "4.2.7.コロン(：)": false,
      "4.3.1.丸かっこ（）": false,
      "4.3.2.大かっこ［］": false,
    },
    "terminology": {
      defaultTerms: true,
    },
  },
};

module.exports = deepmerge(config, localConfig);
