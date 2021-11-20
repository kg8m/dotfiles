#!/usr/bin/env bash
target_filepath="$1"
err_temp_filepath="$(mktemp)"

# shellcheck disable=SC2064
trap "rm -f ${err_temp_filepath}" EXIT

function format_target_filepath {
  local original_target_filepath="$1"

  case "${original_target_filepath}" in
    */COMMIT_EDITMSG)
      # Remove `.git/` because it causes `Not found available plugin for .git/COMMIT_EDITMSG.md` error
      basename "${original_target_filepath}.md"
      ;;
    *)
      echo "${original_target_filepath}"
      ;;
  esac
}

if [ -f "${HOME}/.config/textlint.local/.textlint_wrapper_extends.sh" ]; then
  source "${HOME}/.config/textlint.local/.textlint_wrapper_extends.sh"
fi

options=(
  --format json
  --stdin
  --stdin-filename "$(format_target_filepath "${target_filepath}")"
)

# Kill existing processes because too many processes run and they cause high CPU usage.
pkill -f ".*textlint.* ${options[*]}"

out="$(textlint "${options[@]}" 2> "${err_temp_filepath}")"
err="$(cat "${err_temp_filepath}")"

if [ -n "${out}" ]; then
  format="$(
    printf '%s + ":" + %s + ":" + %s + ": [textlint][" + %s + "] " + %s' \
      '(.line | tostring)' \
      '(.column | tostring)' \
      '(if .severity == 1 then "Warning" else "Error" end)' \
      '.ruleId' \
      '(.message | gsub("\n"; " "))'
  )"
  result="$(echo "${out}" | jq --raw-output ".[0].messages[] | ${format}")"
  echo "${result}"
  [ -n "${result}" ] && exit 1 || exit 0
fi

if [ -n "${err}" ]; then
  detail="$(echo "${err}" | grep -E '✖ Stack trace' -A2 | tail -n2)"

  if [ -z "${detail}" ]; then
    detail="${err}"
  fi

  detail="$(echo "${detail}" | tr '\n' ' ')"
  printf "%s:%s:%s: [textlint] %s\n" "1" "1" "Error" "${detail}"
  exit 1
fi
