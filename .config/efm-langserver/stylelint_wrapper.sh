#!/usr/bin/env bash
if ! command -v stylelint > /dev/null; then
  exit 1
fi

target_filepath="${1:?}"

node_version="$(asdf current nodejs | awk '{ print $2 }')"
config_basedir="${ASDF_DATA_DIR:?}/installs/nodejs/${node_version}/lib"

if [ ! -d "${config_basedir}" ]; then
  echo "_:1:1: ConfigBasedir \`${config_basedir}\` doesn't exist [error]"
  exit 1
fi

options=(
  # For `extends` in `.stylelintrc.js`
  --config-basedir "${config_basedir}"

  --stdin
  --stdin-filename "${target_filepath}"
  --formatter unix
  --no-color
)

stylelint "${options[@]}"
