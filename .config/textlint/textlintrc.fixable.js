const path = require("path");
const fs = require("fs");

const homePath = process.env.HOME;
const configDirpath = path.join(homePath, ".config/textlint");
const localConfigDirpath = path.join(homePath, ".config/textlint.local");

const { deepmerge } = require(path.join(homePath, ".config/util"));

const localConfigPath = path.join(
  localConfigDirpath,
  "textlintrc.fixable.local.js",
);
const localConfig = fs.existsSync(localConfigPath)
  ? require(localConfigPath)
  : {};

const localPrhConfigPath = path.join(localConfigDirpath, "prh-rules.local.yml");
const localPrhConfigPaths = fs.existsSync(localPrhConfigPath)
  ? [localPrhConfigPath]
  : [];

const localTerminologyExclude = localConfig?.rules?.terminology?.exclude;
const config = {
  filters: {
    comments: true,
    "node-types": {
      nodeTypes: ["BlockQuote", "Code", "CodeBlock"],
    },
  },
  rules: {
    // https://github.com/textlint-ja/textlint-rule-no-nfd
    "no-nfd": true,

    // For Japanese contents. Terminology doesn’t work for Japanese.
    prh: {
      rulePaths: ["~/.config/textlint/prh-rules.yml"].concat(
        localPrhConfigPaths,
      ),
    },

    terminology: {
      defaultTerms: true,
      exclude: [
        // Use "filetype"
        // https://github.com/sapegin/textlint-rule-terminology/blob/v4.0.0/terms.jsonc#L149
        "file-?type(s)?",

        // Sometimes `id` is valid.
        // https://github.com/sapegin/textlint-rule-terminology/blob/v4.0.0/terms.jsonc#L89
        "ID",

        // Use "README"
        // https://github.com/sapegin/textlint-rule-terminology/blob/v5.2.3/terms.jsonc#L167
        "readme(s)?",

        // Use "styleguide"
        // https://github.com/sapegin/textlint-rule-terminology/blob/v4.0.0/terms.jsonc#L153
        "style-?guide(s)?",

        // Use a proper noun "Stylelint"
        // https://github.com/sapegin/textlint-rule-terminology/blob/v4.0.0/terms.jsonc#L180
        "(?<=(?:\\w+[^.?!])? )stylelint\\b",

        ...(localTerminologyExclude ?? []),
      ],
    },
  },
};

if (localTerminologyExclude != null) {
  delete localConfig.rules.terminology.exclude;
}

module.exports = deepmerge(config, localConfig);
