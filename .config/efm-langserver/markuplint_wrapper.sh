#!/usr/bin/env bash
if ! command -v markuplint > /dev/null; then
  exit 1
fi

if [ "$(should_use_deno)" = "1" ]; then
  exit 1
fi

# Always use the latest Node.js version for markuplint.
export ASDF_NODEJS_VERSION="$(newest_version nodejs)"

target_filepath="${1:?}"

case "${target_filepath}" in
  *.html.erb)
    # It is a target file; do nothig.
    ;;
  *.erb)
    # Non-HTML ERB files are not supported.
    exit 0
    ;;
esac

# BSD `realpath` doesn't support `--relative-to`.
if command -v grealpath > /dev/null; then
  realpath_bin="grealpath"
else
  realpath_bin="realpath"
fi

# markuplint treats config file's path as relative even if an absolute path is given
absolute_config_filepath="${XDG_CONFIG_HOME:?}/markuplint/markuplint.config.js"
relative_config_filepath="$("${realpath_bin}" --relative-to "${PWD}" "${absolute_config_filepath}")"

options=(
  --config "${relative_config_filepath}"
  --format Simple
  --no-color
  --problem-only
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
