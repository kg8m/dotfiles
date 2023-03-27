module.exports = {
  parser: {
    ".erb$": "@markuplint/erb-parser",
    ".[jt]sx?$": "@markuplint/jsx-parser",
    ".vue$": "@markuplint/vue-parser",
  },

  // https://markuplint.dev/rules
  rules: {
    "attr-duplication": true,
    "character-reference": true,
    "deprecated-attr": true,
    "deprecated-element": true,
    "doctype": true,
    "id-duplication": true,
    "permitted-contents": true,
    "required-attr": true,
    "landmark-roles": true,
    "required-h1": true,
    "class-naming": true,
    "attr-equal-space-after": true,
    "attr-equal-space-before": true,
    "attr-spacing": true,
    "attr-value-quotes": true,
    "case-sensitive-attr-name": true,
    "case-sensitive-tag-name": true,
    "indentation": true,
  },
};
