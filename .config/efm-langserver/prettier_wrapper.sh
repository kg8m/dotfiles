#!/usr/bin/env bash
if ! is_executable prettier; then
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

formatted_filepath="$("${XDG_CONFIG_HOME:?}/efm-langserver/format_filepath" "${target_filepath}")"
options=(
  --stdin-filepath "${formatted_filepath}"
)

case "${formatted_filepath}" in
  *.md)
    if [ -n "${PRETTIER_EMBEDDED_LANGUAGE_FORMATTING:-}" ]; then
      options+=(
        --embedded-language-formatting "${PRETTIER_EMBEDDED_LANGUAGE_FORMATTING:?}"
      )
    fi
    ;;
esac

prettier "${options[@]}"
