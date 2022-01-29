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
  if command -v gsed > /dev/null; then
    sed="gsed"
  else
    sed="sed"
  fi

  out="$(
    "${executable}" "${options[@]}" |
      "${sed}" \
        -e 's/^C:/Convention:/' \
        -e 's/^E:/Error:/' \
        -e 's/^F:/Fatal:/' \
        -e 's/^R:/Refactor:/' \
        -e 's/^W:/Warning:/' \
        -e 's/^\([A-Z]\)\([a-z]\+\): *\([0-9]\+\): *\([0-9]\+\): */\1:\3:\4: [RuboCop][\1\2] /' \
        -e 's/^[CR]:/W:/' \
        -e 's/^F:/E:/'
  )"

  if echo "${out}" | grep -E -q '^[A-Z]:[0-9]+:[0-9]+:'; then
    echo "${out}"
    exit 1
  else
    exit 0
  fi
fi
