#!/usr/bin/env bash
if ! command -v prettier > /dev/null; then
  exit 1
fi

target_filepath="${1:?}"

case "${target_filepath}" in
  *.js | *.jsx | *.mjs | *.mts | *.ts | *.tsx | *.vue)
    if command -v eslint > /dev/null; then
      # Use ESLint as formatter.
      if [ "${ESLINT_AS_FORMATTER:-}" = "1" ] && [ ! "${ESLINT_AND_PRETTIER_AS_FORMATTER:-}" = "1" ]; then
        exit 1
      fi
    else
      if [[ "${target_filepath}" =~ \.ts$ ]]; then
        # Use Deno as formatter.
        if [ "$(should_use_deno)" = "1" ]; then
          exit 1
        fi
      fi
    fi
    ;;
esac

options=(
  --stdin-filepath "$("${XDG_CONFIG_HOME:?}/efm-langserver/format_filepath" "${target_filepath}")"
)

prettier "${options[@]}"
