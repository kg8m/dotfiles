#!/usr/bin/env bash
if ! command -v rubocop > /dev/null; then
  exit 1
fi

if [ ! -f .rubocop.yml ]; then
  exit 1
fi

target_filepath="$1"

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

if command -v rubocop-daemon > /dev/null && command -v rubocop-daemon-wrapper > /dev/null; then
  executable="rubocop-daemon-wrapper"
else
  executable="rubocop"
fi

options=(--force-exclusion --format simple --no-color --stdin "${target_filepath}")

if [ -n "${is_fixing}" ]; then
  "${executable}" "${options[@]}" --auto-correct | awk '/^=+$/,eof' | awk 'NR > 1 { print }'
else
  out="$(
    "${executable}" "${options[@]}" |
        sd '^C:' 'Convention:' |
        sd '^E:' 'Error:' |
        sd '^F:' 'Fatal:' |
        sd '^R:' 'Refactor:' |
        sd '^W:' 'Warning:' |
        sd '^([A-Z])([a-z]+): *([0-9]+): *([0-9]+): *' '$1:$3:$4: [RuboCop][$1$2] ' |
        sd '^[CR]:' 'W:' |
        sd '^F:' 'E:'
  )"

  if echo "${out}" | grep -E -q '^[A-Z]:[0-9]+:[0-9]+:'; then
    echo "${out}"
    exit 1
  else
    exit 0
  fi
fi
