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
    *.js | *.jsx | *.ts | *.tsx)
      # Use ESLint as formatter.
      if [ "${ESLINT_AVAILABLE:-}" = "1" ]; then
        exit 1
      fi
      ;;
  esac
fi

prettier "${options[@]}"
