#!/usr/bin/env bash
target_filepath="${1:?}"
output="$(
  gixy --format json "${target_filepath}" |
    jq --raw-output --from-file "${HOME:?}/.config/efm-langserver/gixy_wrapper.jq"
)"

if [ -n "${output}" ]; then
  echo "${output}"
  exit 1
else
  exit 0
fi
