const path = require("path");
const homePath = process.env["HOME"];
const modulesPath = path.join(homePath, ".local/share/yarn/global/node_modules");

module.exports = {
  extends: [
    path.join(modulesPath, "stylelint-config-standard"),
  ]
}
