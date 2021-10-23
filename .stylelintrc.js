const path = require("path");
const dataHomePath = process.env["XDG_DATA_HOME"];
const modulesPath = path.join(dataHomePath, "yarn/global/node_modules");

module.exports = {
  extends: [
    path.join(modulesPath, "stylelint-config-standard"),
  ],
  rules: {
    "color-hex-length": "long",
    "comment-empty-line-before": null,
    "declaration-empty-line-before": null,
    "no-descending-specificity": null,

    // kebab-case or snake_case
    "selector-class-pattern": "^([a-z][a-z0-9]*)([-_][a-z0-9]+)*$",
    "selector-id-pattern": "^([a-z][a-z0-9]*)([-_][a-z0-9]+)*$",

    "selector-list-comma-newline-after": null,
  },
};
