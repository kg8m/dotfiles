#!/usr/bin/env bash
target_filepath="${1:?}"

if [[ ! "${target_filepath}" == *.github/workflows/* ]]; then
  exit 1
fi

options=(
  -oneline
  -no-color
)

if [ -f ".github/actionlint.yaml" ]; then
  options+=(-config-file ".github/actionlint.yaml")
fi

actionlint "${options[@]}" -
