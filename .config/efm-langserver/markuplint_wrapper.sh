#!/usr/bin/env bash
target_filepath="$1"

# markdownlint treats config file's path as relative even if an absolute path is given
absolute_config_filepath="$HOME/markuplintrc.js"
relative_config_filepath="$(realpath --relative-to "$(pwd)" "$absolute_config_filepath")"

options=(
  --config-file "$relative_config_filepath"
  --format Simple
  --no-color
)

if command -v gsed > /dev/null; then
  sed="gsed"
else
  sed="sed"
fi

out="$(
  markuplint "$target_filepath" "${options[@]}" 2>&1 |
    "$sed" -e 's/^ *//' -e 's/  */ /g'
)"

if [ -n "$out" ]; then
  echo "$out"
  exit 1
fi
