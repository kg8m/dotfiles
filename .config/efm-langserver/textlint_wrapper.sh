#!/usr/bin/env bash
# Always use the latest Node.js version for textlint.
export MISE_NODE_VERSION="latest"

if ! is_executable textlint; then
  exit 1
fi

target_filepath="${1:?}"
err_temp_filepath="$(mktemp)"

# shellcheck disable=SC2064
trap "rm -f '${err_temp_filepath}'" EXIT

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

options=(
  --stdin
  --stdin-filename "$("${XDG_CONFIG_HOME:?}/efm-langserver/format_filepath" "${target_filepath}")"
)

if [ "${is_fixing}" = "1" ]; then
  options+=(
    --fix
    --dry-run
    --format fixed-result
  )

  # Enable only a few rules for performance and preventing unintended fixes.
  options+=(
    --config ~/.config/textlint/textlintrc.fixable.js
  )
else
  options+=(
    --config ~/.config/textlint/textlintrc.js
    --format json
  )
fi

# Kill existing processes because too many processes run and they cause high CPU usage.
pkill -f ".*textlint.* ${options[*]}"

out="$(textlint "${options[@]}" 2> "${err_temp_filepath}")"
err="$(< "${err_temp_filepath}")"

if [[ "${out}" =~ No\ rules\ found, ]]; then
  err="${out}"
  out=""
fi

if [ -n "${out}" ]; then
  if [ "${is_fixing}" = "1" ]; then
    echo "${out}"
    exit 0
  else
    jq_options=(
      --raw-output
      --from-file "${XDG_CONFIG_HOME:?}/efm-langserver/textlint_wrapper.jq"
    )

    result="$(echo "${out}" | jq "${jq_options[@]}")"

    echo "${result}"
    [ -n "${result}" ] && exit 1 || exit 0
  fi
fi

if [ -n "${err}" ]; then
  detail="$(echo "${err}" | rg '✖ Stack trace' -A2 | tail -n2)"

  if [ -z "${detail}" ]; then
    detail="${err}"
  fi

  detail="$(echo "${detail}" | tr '\n' ' ')"
  printf "%s:%s:%s: %s\n" "1" "1" "Error" "${detail}"
  exit 1
fi

if [ "${is_fixing}" = "1" ]; then
  # Treat as failure if both stdout and stderr are empty in order to avoid unintended formatting.
  exit 1
fi
