#!/usr/bin/env bash
if ! command -v sql-formatter > /dev/null; then
  exit 1
fi

# Always use the latest Node.js version for sql-formatter.
export ASDF_NODEJS_VERSION="$(asdf list nodejs | tail -n1)"

options=(
  --config "${XDG_CONFIG_HOME:?}/sql-formatter/config.json"
)

sql-formatter "${options[@]}"
