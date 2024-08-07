#!/usr/bin/env bash
if ! command -v sql-formatter > /dev/null; then
  exit 1
fi

# Always use the latest Node.js version for sql-formatter.
export ASDF_NODEJS_VERSION="$(newest_version nodejs)"

options=(
  --config "${XDG_CONFIG_HOME:?}/sql-formatter/config.json"
)

if [ -n "${SQL_FORMATTER_LANGUAGE:-}" ]; then
  options+=(
    --language "${SQL_FORMATTER_LANGUAGE:?}"
  )
fi

sql-formatter "${options[@]}"
