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

if [ ! "${USE_RUBOCOP_FOR_MARKDOWN:-}" = "1" ] && [[ "${target_filepath}" =~ \.md$ ]]; then
  echo "Running for Markdown files isn't supported." >&2
  exit 1
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

# --force-exclusion
#   Any files excluded by `Exclude` in configuration files will be excluded, even if given explicitly as arguments.
# --stdin FILE
#   Pipe source from STDIN, using FILE in offense reports. This is useful for editor integration.
options+=(--force-exclusion --no-color --stdin "${target_filepath}")

if [ "${is_fixing}" = "1" ]; then
  if [[ "${target_filepath}" =~ \.md$ ]]; then
    echo "Formatting Markdown files from STDIN source isn't supported." >&2
    exit 1
  fi

  err_temp_filepath="$(mktemp)"

  # shellcheck disable=SC2064
  trap "rm -f ${err_temp_filepath}" EXIT

  # --stderr
  #   Write all output to stderr except for the autocorrected source. This is especially useful when combined with
  #   --autocorrect and --stdin.
  out="$("${executable}" "${options[@]}" --autocorrect --stderr 2> "${err_temp_filepath}")"

  if [ -n "${out}" ]; then
    echo "${out}"
  else
    cat "${err_temp_filepath}" >&2
    exit 1
  fi
else
  out="$("${executable}" "${options[@]}" --format simple | sd '^([A-Z]): *([0-9]+): *([0-9]+): *' '$1:$2:$3: ')"

  if echo "${out}" | grep -E -q '^[A-Z]:[0-9]+:[0-9]+:'; then
    echo "${out}"
    exit 1
  else
    exit 0
  fi
fi
