const path = require("path");
const dataHomePath = process.env["XDG_DATA_HOME"];
const modulesPath = path.join(dataHomePath, "yarn/global/node_modules");

module.exports = {
  extends: [
    path.join(modulesPath, "stylelint-config-standard"),
  ]
}
