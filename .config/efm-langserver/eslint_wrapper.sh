#!/usr/bin/env bash
target_filepath="$1"
err_temp_filepath="/tmp/textlint_wrapper_$( date +'%Y%m%d-%H%M%S' ).${RANDOM}.log"

if [ "$2" = "--fix" ]; then
  fix_enabled="1"
fi

if [ -n "$fix_enabled" ] && [ -z "$VIM_FIX_ON_SAVE_JS" ]; then
  exit 0
fi

function is_target_file {
  echo 1
}

function eslint_wrapper_options {
  echo ""
}

if [ -f .eslint_wrapper_extends.sh ]; then
  source .eslint_wrapper_extends.sh
fi

if [ ! "$( is_target_file "$target_filepath" )" = "1" ]; then
  exit 0
fi

if command -v eslint_d > /dev/null 2>&1; then
  executable=eslint_d
else
  executable=eslint
fi

options=( --format json --stdin --stdin-filename "$target_filepath" )

if [ -n "$fix_enabled" ]; then
  if [ "$executable" = "eslint_d" ]; then
    options=( "${options[@]}" --fix-to-stdout )
  else
    options=( "${options[@]}" --fix-dry-run )
  fi
fi

options=( "${options[@]}" "$( eslint_wrapper_options "$target_filepath" )" )

out="$( "$executable" "${options[@]}" 2>"$err_temp_filepath" )"
err="$( cat "$err_temp_filepath" )"

rm -f "$err_temp_filepath"

if [ -n "$out" ]; then
  if [ -n "$fix_enabled" ]; then
    if [ "$executable" = "eslint_d" ]; then
      echo "$out"
    else
      echo "$out" | jq --raw-output ".[0].output"
    fi

    exit 0
  else
    format="$(
      printf '"%s: line " + %s + ", col " + %s + ", " + %s + " - [eslint][" + %s + "] " + %s' \
        "$target_filepath" \
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
  detail="$( echo "$err" | egrep -v '^Oops!|^ESLint:|^[ ]|^$' )"

  if [ -z "$detail" ]; then
    detail="$err"
  fi

  detail="$( echo "$detail" | tr '\n' ' ' )"
  printf "%s: line %s, col %s, %s - [eslint] %s\n" "$target_filepath" "1" "1" "Error" "$detail"
  exit 1
fi
