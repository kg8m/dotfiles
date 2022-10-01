#!/usr/bin/env bash
if ! command -v markuplint > /dev/null; then
  exit 1
fi

# Always use the latest Node.js version for markuplint.
export ASDF_NODEJS_VERSION="$(newest_version nodejs)"

target_filepath="${1:?}"

# markuplint treats config file's path as relative even if an absolute path is given
absolute_config_filepath="${HOME}/markuplintrc.js"
relative_config_filepath="$(realpath --relative-to "${PWD}" "${absolute_config_filepath}")"

options=(
  --config "${relative_config_filepath}"
  --format Simple
  --no-color
)

out="$(
  markuplint "${target_filepath}" "${options[@]}" 2>&1 |
    sd '^ *' '' |
    sd '  *' ' '
)"

if [ -n "${out}" ]; then
  echo "${out}"
  exit 1
fi
