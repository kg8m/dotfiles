#!/usr/bin/env bash
if ! command -v prettier > /dev/null; then
  exit 1
fi

target_filepath="${1:?}"

if command -v eslint > /dev/null; then
  case "${target_filepath}" in
    *.js | *.jsx | *.ts | *.tsx | *.vue)
      # Use ESLint as formatter.
      if [ "${ESLINT_AS_FORMATTER:-}" = "1" ] && [ ! "${ESLINT_AND_PRETTIER_AS_FORMATTER:-}" = "1" ]; then
        exit 1
      fi
      ;;
  esac
fi

options=(
  --stdin-filepath "$("${XDG_CONFIG_HOME:?}/efm-langserver/format_filepath" "${target_filepath}")"
)

prettier "${options[@]}"
