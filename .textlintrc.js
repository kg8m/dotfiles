module.exports = {
  filters: {
    comments: true,
    "node-types": {
      nodeTypes: ["BlockQuote", "CodeBlock"],
    },
  },
  rules: {
    "@textlint-ja/no-synonyms": true,
    "@textlint-ja/textlint-rule-no-insert-dropping-sa": true,
    "date-weekday-mismatch": { lang: "ja-JP" },
    "ja-hiragana-keishikimeishi": true,
    "joyo-kanji": true,

    // Disable because there are too many false positives
    "no-hoso-kinshi-yogo": false,

    "prefer-tari-tari": true,
    "preset-ja-technical-writing": {
      "ja-no-weak-phrase": false,
      "ja-no-mixed-period": false,
      "no-doubled-joshi": {
        allow: ["か", "にも"],
      },
      "no-exclamation-question-mark": false,
      "sentence-length": {
        max: 100,
        exclusionPatterns: [
          "/\\bhttps?:\\/\\/[^\\s)>]+/",
        ],
      },
    },
    "preset-jtf-style": {
      "3.1.1.全角文字と半角文字の間": false,
      "3.1.2.全角文字どうし": false,
      "3.3.かっこ類と隣接する文字の間のスペースの有無": false,
      "4.2.1.感嘆符(！)": false,
      "4.2.2.疑問符(？)": false,
      "4.2.7.コロン(：)": false,
      "4.3.1.丸かっこ（）": false,
      "4.3.2.大かっこ［］": false,
    },
    "terminology": {
      defaultTerms: true,
    },
  },
};
