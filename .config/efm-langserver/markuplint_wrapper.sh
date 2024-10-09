#!/usr/bin/env bash
# Always use the latest Node.js version for markuplint.
export MISE_NODE_VERSION="latest"

if [ "$(should_use_deno)" = "1" ]; then
  exit 1
fi

if ! is_executable markuplint; then
  exit 1
fi

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

# markuplint treats config file’s path as relative even if an absolute path is given
absolute_config_filepath="${XDG_CONFIG_HOME:?}/markuplint/markuplint.config.js"
relative_config_filepath="$(to_relative_path "${absolute_config_filepath}")"

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
