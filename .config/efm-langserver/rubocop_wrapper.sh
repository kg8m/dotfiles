#!/usr/bin/env bash
if ! command -v rubocop > /dev/null; then
  exit 1
fi

if [ ! -f .rubocop.yml ]; then
  exit 1
fi

target_filepath="${1:?}"

if [ "$2" = "--fix" ]; then
  is_fixing="1"
fi

options=()

if rubocop --server-status > /dev/null 2>&1; then
  executable="rubocop"
  options+=("--server")
elif command -v rubocop-daemon > /dev/null && command -v rubocop-daemon-wrapper > /dev/null; then
  executable="rubocop-daemon-wrapper"
else
  executable="rubocop"
fi

options+=(--force-exclusion --format simple --no-color --stdin "${target_filepath}")

if [ "${is_fixing}" = "1" ]; then
  if [[ "${target_filepath}" =~ \.md$ ]]; then
    echo "Formatting Markdown files from STDIN source isn't supported." >&2
    exit 1
  fi

  result="$("${executable}" "${options[@]}" --autocorrect)"

  if echo "${result}" | grep -E '^=+$' -q; then
    echo "${result}" | awk '/^=+$/,eof' | awk 'NR > 1 { print }'
  else
    echo "${result}" >&2
    exit 1
  fi
else
  out="$("${executable}" "${options[@]}" | sd '^([A-Z]): *([0-9]+): *([0-9]+): *' '$1:$2:$3: ')"

  if echo "${out}" | grep -E -q '^[A-Z]:[0-9]+:[0-9]+:'; then
    echo "${out}"
    exit 1
  else
    exit 0
  fi
fi
