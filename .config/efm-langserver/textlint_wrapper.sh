#!/usr/bin/env bash
target_filepath="$1"
err_temp_filepath="/tmp/textlint_wrapper_$( date +'%Y%m%d-%H%M%S' ).${RANDOM}.log"

out="$( textlint --format json --stdin --stdin-filename "$target_filepath" 2>"$err_temp_filepath" )"
err="$( cat "$err_temp_filepath" )"

rm -fr "$err_temp_filepath"

if [ -n "$out" ]; then
  format="$(
    printf '"%s: line " + %s + ", col " + %s + ", " + %s + " - [textlint][" + %s + "] " + %s' \
      "$target_filepath" \
      '(.line | tostring)' \
      '(.column | tostring)' \
      '(if .severity == 1 then "Warning" else "Error" end)' \
      '.ruleId' \
      '(.message | gsub("\n"; " "))'
  )"
  echo "$out" | jq --raw-output ".[0].messages[] | $format"
  exit 1
fi

if [ -n "$err" ]; then
  detail="$( echo "$err" | egrep '✖ Stack trace' -A2 | tail -n2 )"

  if [ -z "$detail" ]; then
    detail="$err"
  fi

  detail="$( echo "$detail" | tr '\n' ' ' )"
  printf "%s: line %s, col %s, %s - [textlint] %s\n" "$target_filepath" "1" "1" "Error" "$detail"
  exit 1
fi
