const path = require("path");
const fs = require("fs");

const homePath = process.env.HOME;
const localConfigPath = path.join(process.env.PWD, ".markuplintrc.js");
const { deepmerge } = require(path.join(homePath, ".config/util"));

const localConfig = fs.existsSync(localConfigPath)
  ? require(localConfigPath)
  : {};

// https://markuplint.dev/ja/docs/configuration
const config = {
  parser: {
    ".erb$": "@markuplint/erb-parser",
    ".[jt]sx?$": "@markuplint/jsx-parser",
    ".vue$": "@markuplint/vue-parser",
  },

  // https://markuplint.dev/rules
  rules: {
    "attr-duplication": true,
    "attr-value-quotes": true,
    "case-sensitive-attr-name": true,
    "case-sensitive-tag-name": true,
    "character-reference": true,
    "class-naming": "/^[a-z][a-z0-9]*(?:-[a-z0-9]+)*$/",
    "deprecated-attr": true,
    "deprecated-element": true,
    "end-tag": true,
    "id-duplication": true,
    "ineffective-attr": true,
    "invalid-attr": true,
    "label-has-control": true,
    "landmark-roles": true,
    "no-boolean-attr-value": true,
    "no-default-value": true,
    "no-empty-palpable-content": true,
    "no-hard-code-id": true,
    "no-refer-to-non-existent-id": true,
    "no-use-event-handler-attr": true,
    "permitted-contents": true,
    "placeholder-label-option": true,
    "require-accessible-name": true,
    "require-datetime": true,
    "required-attr": true,
    "use-list": true,
    "wai-aria": true,
  },

  nodeRules: [{ selector: "slot", rules: { "end-tag": false } }],
};

if (process.env.USE_VUEJS === "1") {
  config.nodeRules.push({
    selector: "script",
    rules: {
      "invalid-attr": {
        options: { allowAttrs: ["setup"] },
      },
    },
  });
}

module.exports = deepmerge(config, localConfig);
