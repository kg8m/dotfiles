module.exports = {
  parser: {
    ".erb$": "@markuplint/erb-parser",
    ".[jt]sx?$": "@markuplint/jsx-parser",
    ".vue$": "@markuplint/vue-parser",
  },

  // https://markuplint.dev/rules
  rules: {
    "attr-duplication": true,
    "attr-equal-space-after": true,
    "attr-equal-space-before": true,
    "attr-spacing": true,
    "attr-value-quotes": true,
    "case-sensitive-attr-name": true,
    "case-sensitive-tag-name": true,
    "character-reference": true,
    "class-naming": true,
    "deprecated-attr": true,
    "deprecated-element": true,
    doctype: true,
    "id-duplication": true,
    indentation: true,
    "landmark-roles": true,
    "permitted-contents": true,
    "required-attr": true,
    "required-h1": true,
  },
};
