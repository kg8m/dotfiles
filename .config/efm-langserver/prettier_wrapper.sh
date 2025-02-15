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

formatted_target_filepath="$("${XDG_CONFIG_HOME:?}/efm-langserver/format_filepath" "${target_filepath}")"
options=(
  --stdin-filepath "${formatted_target_filepath}"
)

# Use my own configurations if there is no editorconfig or prettierrc file.
if [ ! -f ".editorconfig" ]; then
  # OPTIMIZE: Check `$PRETTIER_CONFIG_FILEPATH` first because `prettier --find-config-path` is a bit slow.
  if [ "${PRETTIER_CONFIG_FILEPATH+x}" = "x" ]; then
    if [ -n "${PRETTIER_CONFIG_FILEPATH:-}" ]; then
      options+=(
        --config "${PRETTIER_CONFIG_FILEPATH:?}"
      )
    fi
  else
    config_filepath="$(prettier --find-config-path "${formatted_target_filepath}" 2> /dev/null)"

    if [ -z "${config_filepath}" ]; then
      options+=(
        --config "${XDG_CONFIG_HOME:?}/prettier/.prettierrc.yaml"
      )
    fi
  fi
fi

case "${formatted_target_filepath}" in
  *.md)
    if [ -n "${PRETTIER_EMBEDDED_LANGUAGE_FORMATTING:-}" ]; then
      options+=(
        --embedded-language-formatting "${PRETTIER_EMBEDDED_LANGUAGE_FORMATTING:?}"
      )
    fi
    ;;
esac

prettier "${options[@]}"
