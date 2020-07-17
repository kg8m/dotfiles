module.exports = {
  filters: {
    comments: true,
  },
  rules: {
    "textlint-rule-preset-ja-technical-writing": {
      "ja-no-weak-phrase": false,
      "ja-no-mixed-period": false,
      "no-doubled-joshi": {
        allow: ["か", "にも"],
      },
      "no-exclamation-question-mark": false,
    },
    "textlint-rule-preset-jtf-style": {
      "3.1.1.全角文字と半角文字の間": false,
      "3.1.2.全角文字どうし": false,
      "3.3.かっこ類と隣接する文字の間のスペースの有無": false,
      "4.2.1.感嘆符(！)": false,
      "4.2.2.疑問符(？)": false,
      "4.2.7.コロン(：)": false,
      "4.3.2.大かっこ［］": false,
    },
  },
};
