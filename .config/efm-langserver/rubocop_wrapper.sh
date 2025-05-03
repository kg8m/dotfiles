#!/usr/bin/env bash
if [ ! -f .rubocop.yml ]; then
  exit 1
fi

target_filepath="${1:?}"

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

# Use LSP mode RuboCop for non-Markdown files as default.
# cf. .config/vim/autoload/kg8m/plugin/lsp/servers.vim
if [ ! "${USE_RUBOCOP_LSP:-}" = "0" ] && [[ ! "${target_filepath}" == *.md ]]; then
  echo "Use LSP mode RuboCop for ${target_filepath}." >&2
  exit 1
fi

if [ ! "${USE_RUBOCOP_FOR_MARKDOWN:-}" = "1" ] && [[ "${target_filepath}" == *.md ]]; then
  echo "Running for Markdown files isn’t supported." >&2
  exit 1
fi

if [ ! "${USE_RUBOCOP_FOR_RBS:-}" = "1" ] && [[ "${target_filepath}" == *.rbs ]]; then
  echo "Running for RBS files isn’t supported." >&2
  exit 1
fi

if [ ! "${USE_RUBOCOP_FOR_SLIM:-}" = "1" ] && [[ "${target_filepath}" == *.slim ]]; then
  echo "Running for Slim files isn’t supported." >&2
  exit 1
fi

options=()

# Use rubocop-daemon as default. Overwrite the command if needed.
if [ -n "${RUBOCOP_WRAPPER_COMMAND:-}" ]; then
  executable="${RUBOCOP_WRAPPER_COMMAND:?}"
else
  executable="rubocop-daemon-wrapper"
fi

if ! is_executable "${executable}"; then
  exit 1
fi

# --force-exclusion
#   Any files excluded by `Exclude` in configuration files will be excluded, even if given explicitly as arguments.
# --stdin FILE
#   Pipe source from STDIN, using FILE in offense reports. This is useful for editor integration.
options+=(--force-exclusion --no-color --stdin "${target_filepath}")

if [ "${is_fixing}" = "1" ]; then
  if [[ "${target_filepath}" == *.md ]]; then
    echo "Formatting Markdown files from STDIN source isn’t supported." >&2
    exit 1
  fi

  err_temp_filepath="$(mktemp)"

  # shellcheck disable=SC2064
  trap "rm -f '${err_temp_filepath}'" EXIT

  if [ -n "${RUBOCOP_WRAPPER_FIX_OPTIONS:-}" ]; then
    read -r -a local_options <<< "${RUBOCOP_WRAPPER_FIX_OPTIONS}"
    options+=("${local_options[@]}")
  else
    options+=(--autocorrect)
  fi

  case "${executable}" in
    rubocop-daemon-wrapper)
      out="$("${executable}" "${options[@]}" | awk '/^=+$/,eof' | awk 'NR > 1 { print }' 2> "${err_temp_filepath}")"
      ;;
    *)
      options+=(
        # --stderr
        #   Write all output to stderr except for the autocorrected source. This is especially useful when combined with
        #   --autocorrect and --stdin.
        --stderr
      )

      out="$("${executable}" "${options[@]}" 2> "${err_temp_filepath}")"
      ;;
  esac

  if [ -n "${out}" ]; then
    echo "${out}"
  else
    cat "${err_temp_filepath}" >&2
    exit 1
  fi
else
  out="$("${executable}" "${options[@]}" --format simple | sd '^([A-Z]): *([0-9]+): *([0-9]+): *' '$1:$2:$3: ')"

  if echo "${out}" | rg -q '^[A-Z]:[0-9]+:[0-9]+:'; then
    echo "${out}"
    exit 1
  else
    exit 0
  fi
fi
