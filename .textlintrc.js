module.exports = {
  filters: {
    comments: true,
  },
  rules: {
    "textlint-rule-preset-ja-technical-writing": {
      "ja-no-weak-phrase": false,
      "no-exclamation-question-mark": false,
    },
    "textlint-rule-preset-jtf-style": {
      "3.1.1.全角文字と半角文字の間": false,
      "4.2.7.コロン(：)": false,
      "4.2.1.感嘆符(！)": false,
    },
  },
};
