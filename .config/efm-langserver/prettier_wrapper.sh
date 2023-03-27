#!/usr/bin/env bash
if ! command -v prettier > /dev/null; then
  exit 1
fi

target_filepath="${1:?}"

options=(
  --stdin-filepath "${target_filepath}"
)

if command -v eslint > /dev/null; then
  case "${target_filepath}" in
    *.js | *.jsx | *.ts | *.tsx | *.vue)
      # Use ESLint as formatter.
      if [ "${ESLINT_AS_FORMATTER:-}" = "1" ]; then
        exit 1
      fi
      ;;
  esac
fi

prettier "${options[@]}"
