#!/usr/bin/env bash
if ! is_executable erblint; then
  exit 1
fi

target_filepath="${1:?}"

if [ -f ".erb-lint.yml" ]; then
  config=".erb-lint.yml"
else
  config="${HOME}/.config/erb-lint/.erb-lint.yml"
fi

erblint --config "${config}" --format compact --stdin "${target_filepath}"
