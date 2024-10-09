#!/usr/bin/env bash
if ! is_executable brakeman; then
  exit 1
fi

target_filepath="${1:?}"
relative_filepath="${target_filepath/${PWD}\//}"

# Don’t use `--only-files` option because Brakeman requires all project files for accurate diagnostic.
# For example, the `UnscopedFind` check doesn’t work without model files.
brakeman_options=(
  --quiet
  --run-all-checks
  --format "json"
)

jq_options=(
  --raw-output
  --from-file "${XDG_CONFIG_HOME:?}/efm-langserver/brakeman_wrapper.jq"
  --arg filepath "${relative_filepath}"
)

out="$(brakeman "${brakeman_options[@]}" | jq "${jq_options[@]}")"

if [ -n "${out}" ]; then
  echo "${out}"
  exit 1
fi
