#!/usr/bin/env bash
if [ ! "${USE_ESLINT:-}" = "1" ]; then
  exit 1
fi

target_filepath="${1:?}"

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

if [ "${is_fixing}" = "1" ]; then
  if [ ! "${ESLINT_AS_FORMATTER:-}" = "1" ] && [ ! "${ESLINT_AND_PRETTIER_AS_FORMATTER:-}" = "1" ]; then
    exit 1
  fi
fi

if ! is_executable eslint; then
  exit 1
fi

err_temp_filepath="$(mktemp)"

# shellcheck disable=SC2064
trap "rm -f '${err_temp_filepath}'" EXIT

function is_target_file {
  echo 1
}

function eslint_wrapper_options {
  echo ""
}

if [ -f .eslint_wrapper_extends.sh ]; then
  source .eslint_wrapper_extends.sh
fi

if [ ! "$(is_target_file "${target_filepath}")" = "1" ]; then
  exit 1
fi

if is_executable eslint_d; then
  executable=eslint_d
else
  executable=eslint
fi

options=(--format json --stdin --stdin-filename "${target_filepath}")

if [ "${is_fixing}" = "1" ]; then
  if [ "${executable}" = "eslint_d" ]; then
    options+=(--fix-to-stdout)
  else
    options+=(--fix-dry-run)
  fi
fi

options+=("$(eslint_wrapper_options "${target_filepath}")")

# Kill existing processes because too many processes run and they cause high CPU usage.
pkill -f ".*${executable} .* ${options[*]}"

out="$("${executable}" "${options[@]}" 2> "${err_temp_filepath}")"
err="$(< "${err_temp_filepath}")"

if [ -n "${out}" ]; then
  if [ "${is_fixing}" = "1" ]; then
    if [ "${executable}" = "eslint_d" ]; then
      echo "${out}"
      exit 0
    else
      output="$(echo "${out}" | jq --raw-output ".[0].output")"

      if [ "${output}" = "null" ]; then
        exit 1
      else
        echo "${output}"
        exit 0
      fi
    fi
  else
    jq_options=(
      --raw-output
      --from-file "${XDG_CONFIG_HOME:?}/efm-langserver/eslint_wrapper.jq"
    )

    echo "${out}" | jq "${jq_options[@]}"
    exit 1
  fi
fi

if [ -n "${err}" ]; then
  detail="$(echo "${err}" | rg -v '^Oops!|^ESLint:|^[ ]|^$')"

  if [ -z "${detail}" ]; then
    detail="${err}"
  fi

  detail="$(echo "${detail}" | tr '\n' ' ')"
  printf "%s:%s:%s: %s\n" "1" "1" "Error" "${detail}"
  exit 1
fi
