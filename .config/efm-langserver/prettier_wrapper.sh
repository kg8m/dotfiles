#!/usr/bin/env bash
if ! is_executable prettier; then
  exit 1
fi

target_filepath="${1:?}"

case "${target_filepath}" in
  *.js | *.jsx | *.mjs | *.mts | *.ts | *.tsx | *.vue)
    if is_executable eslint; then
      # Use ESLint as a formatter.
      if [ "${ESLINT_AS_FORMATTER:-}" = "1" ] && [ ! "${ESLINT_AND_PRETTIER_AS_FORMATTER:-}" = "1" ]; then
        exit 1
      fi
    else
      if [[ "${target_filepath}" == *.ts ]]; then
        # Use Deno as a formatter.
        if [ "$(should_use_deno)" = "1" ]; then
          exit 1
        fi
      fi
    fi
    ;;
  *.md)
    # Use Deno as a formatter.
    if [ "${USE_DENO_FOR_MARKDOWN:-}" = "1" ]; then
      exit 1
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
