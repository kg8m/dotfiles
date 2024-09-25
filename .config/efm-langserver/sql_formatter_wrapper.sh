#!/usr/bin/env bash
# Always use the latest Node.js version for sql-formatter.
export MISE_NODE_VERSION="latest"

if ! command -v sql-formatter > /dev/null; then
  exit 1
fi

options=(
  --config "${XDG_CONFIG_HOME:?}/sql-formatter/config.json"
)

if [ -n "${SQL_FORMATTER_LANGUAGE:-}" ]; then
  options+=(
    --language "${SQL_FORMATTER_LANGUAGE:?}"
  )
fi

sql-formatter "${options[@]}"
