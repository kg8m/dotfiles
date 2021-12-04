const path = require("path");
const fs = require("fs");

const homePath = process.env["HOME"];
const configDirpath = path.join(homePath, ".config/textlint");
const localConfigDirpath = path.join(homePath, ".config/textlint.local");

const { deepmerge } = require(path.join(configDirpath, "util"));

const localConfigPath = path.join(localConfigDirpath, ".textlintrc.fixable.local.js");
const localConfig = fs.existsSync(localConfigPath) ? require(localConfigPath) : {};

const localPrhConfigPath = path.join(localConfigDirpath, "prh-rules.local.yml");
const localPrhConfigPaths = fs.existsSync(localPrhConfigPath) ? [localPrhConfigPath] : [];

const config = {
  filters: {
    comments: true,
    "node-types": {
      nodeTypes: ["BlockQuote", "Code", "CodeBlock"],
    },
  },
  rules: {
    // For Japanese contents. Terminology doesn't work for Japanese.
    "prh": {
      rulePaths: ["~/.config/textlint/prh-rules.yml"].concat(localPrhConfigPaths),
    },

    "terminology": {
      defaultTerms: true,
    },
  },
};

module.exports = deepmerge(config, localConfig);
