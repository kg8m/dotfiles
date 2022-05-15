#!/usr/bin/env bash
if ! command -v stylelint > /dev/null; then
  exit 1
fi

node_version="$(asdf current nodejs | awk '{ print $2 }')"
config_basedir="${ASDF_DATA_DIR:?}/installs/nodejs/${node_version}/.npm/lib"

if [ ! -d "${config_basedir}" ]; then
  echo "_:1:1: ConfigBasedir \`${config_basedir}\` doesn't exist [error]"
  exit 1
fi

options=(
  --config-basedir "${config_basedir}"
  --stdin
  --stdin-filename /dummy.css
  --formatter unix
  --no-color
)

stylelint "${options[@]}"
