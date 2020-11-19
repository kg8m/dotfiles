#!/usr/bin/env bash
if ! command -v eslint > /dev/null 2>&1; then
  exit 1
fi

target_filepath="$1"
err_temp_filepath="$(mktemp)"

# shellcheck disable=SC2064
trap "rm -f $err_temp_filepath" EXIT

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

if [ -n "$is_fixing" ] && [ -z "${VIM_FIX_ON_SAVE_JS:-}" ]; then
  exit 1
fi

function is_target_file {
  echo 1
}

function eslint_wrapper_options {
  echo ""
}

if [ -f .eslint_wrapper_extends.sh ]; then
  # shellcheck disable=SC1091
  source .eslint_wrapper_extends.sh
fi

if [ ! "$(is_target_file "$target_filepath")" = "1" ]; then
  exit 1
fi

if command -v eslint_d > /dev/null 2>&1; then
  executable=eslint_d
else
  executable=eslint
fi

options=(--format json --stdin --stdin-filename "$target_filepath")

if [ -n "$is_fixing" ]; then
  if [ "$executable" = "eslint_d" ]; then
    options+=(--fix-to-stdout)
  else
    options+=(--fix-dry-run)
  fi
fi

options+=("$(eslint_wrapper_options "$target_filepath")")

out="$("$executable" "${options[@]}" 2> "$err_temp_filepath")"
err="$(cat "$err_temp_filepath")"

if [ -n "$out" ]; then
  if [ -n "$is_fixing" ]; then
    if [ "$executable" = "eslint_d" ]; then
      echo "$out"
    else
      echo "$out" | jq --raw-output ".[0].output"
    fi

    exit 0
  else
    format="$(
      printf '%s + ":" + %s + ":" + %s + ": [eslint][" + %s + "] " + %s' \
        '(.line | tostring)' \
        '(if .column == null then "1" else .column | tostring end)' \
        '(if .severity == 1 then "Warning" else "Error" end)' \
        '.ruleId' \
        '(.message | gsub("\n"; " "))'
    )"
    echo "$out" | jq --raw-output ".[0].messages[] | $format"
    exit 1
  fi
fi

if [ -n "$err" ]; then
  detail="$(echo "$err" | grep -E -v '^Oops!|^ESLint:|^[ ]|^$')"

  if [ -z "$detail" ]; then
    detail="$err"
  fi

  detail="$(echo "$detail" | tr '\n' ' ')"
  printf "%s:%s:%s: [eslint] %s\n" "1" "1" "Error" "$detail"
  exit 1
fi
