#!/usr/bin/env bash
if ! command -v sql-formatter > /dev/null; then
  exit 1
fi

options=(
  --config "${XDG_CONFIG_HOME:?}/sql-formatter/config.json"
)

sql-formatter "${options[@]}"
