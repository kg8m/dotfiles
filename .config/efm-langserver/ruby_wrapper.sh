#!/usr/bin/env bash
if ! command -v ruby > /dev/null; then
  exit 1
fi

target_filepath="${1:?}"

options=(-c)

if [ -z "${DISABLE_RUBY_WARNINGS:-}" ]; then
  options+=(-w)
fi

out="$(
  ruby "${options[@]}" "${target_filepath}" 2>&1 1> /dev/null |
    grep -E -o '[0-9]+: (warning:)?.*$' |
    sd '^([0-9]+): *' '$1: [Ruby] '
)"

if [ -n "${out}" ]; then
  echo "${out}"
  exit 1
fi
