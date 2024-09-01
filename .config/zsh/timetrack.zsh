TIMETRACK_IGNORE_PATTERN="^$"
TIMETRACK_IGNORE_PATTERN+="| --help$"
TIMETRACK_IGNORE_PATTERN+="|\bNO_TIMETRACK\b"
TIMETRACK_IGNORE_PATTERN+="|\baws configure\b"
TIMETRACK_IGNORE_PATTERN+="|\bbat\b"
TIMETRACK_IGNORE_PATTERN+="|^eza\b"
TIMETRACK_IGNORE_PATTERN+="|\bless\b|\bL$"
TIMETRACK_IGNORE_PATTERN+="|^man "
TIMETRACK_IGNORE_PATTERN+="|\bmy_grep:with_filter\b"
TIMETRACK_IGNORE_PATTERN+="|\bmy_diff(:without_spaces)?\b"
TIMETRACK_IGNORE_PATTERN+="|\bvim?\b|\bV$"
TIMETRACK_IGNORE_PATTERN+="|\byard:server\b"
TIMETRACK_PATTERN="^$"
TIMETRACK_PATTERN+="|\b7z\b"
TIMETRACK_PATTERN+="|\bansible\b"
TIMETRACK_PATTERN+="|\basdf (install|plugin-update|reshim|uninstall|update)\b"
TIMETRACK_PATTERN+="|\bbenchmark"
TIMETRACK_PATTERN+="|\b(bin/|bundle exec )?rails (db:|g|new\b|r|t)"
TIMETRACK_PATTERN+="|\b(bin/|bundle exec )?rake\b"
TIMETRACK_PATTERN+="|\b(bundle exec )?r?spec\b"
TIMETRACK_PATTERN+="|\b(bundle exec )?ruby\b"
TIMETRACK_PATTERN+="|\bbundle( install)?$"
TIMETRACK_PATTERN+="|\bbrew\b"
TIMETRACK_PATTERN+="|\bcat\b"
TIMETRACK_PATTERN+="|\bconfigure\b"
TIMETRACK_PATTERN+="|\bcp\b"
TIMETRACK_PATTERN+="|\berblint\b"
TIMETRACK_PATTERN+="|\bfd\b"
TIMETRACK_PATTERN+="|\bfind\b"
TIMETRACK_PATTERN+="|\bfor\b"
TIMETRACK_PATTERN+="|\bgh run watch\b"
TIMETRACK_PATTERN+="|\bgit (shallow-)?(clone|f|push|up)"
TIMETRACK_PATTERN+="|\bgo\b"
TIMETRACK_PATTERN+="|\bgzip\b"
TIMETRACK_PATTERN+="|\bhyperfine\b"
TIMETRACK_PATTERN+="|\bmake\b"
TIMETRACK_PATTERN+="|\bmv\b"
TIMETRACK_PATTERN+="|\bmysql .*( -e|<)"
TIMETRACK_PATTERN+="|\bmysqldump\b"
TIMETRACK_PATTERN+="|\bnpm (exec|i|install|init|run)\b"
TIMETRACK_PATTERN+="|\bpv\b"
TIMETRACK_PATTERN+="|\b(rails|rake) stats\b"
TIMETRACK_PATTERN+="|\brails:assets:\b"
TIMETRACK_PATTERN+="|\brbenv\b"
TIMETRACK_PATTERN+="|\bridgepole\b"
TIMETRACK_PATTERN+="|\brsync\b"
TIMETRACK_PATTERN+="|\brubocop(-daemon)?\b"
TIMETRACK_PATTERN+="|\bscp\b"
TIMETRACK_PATTERN+="|\bssh +[a-z0-9_.@]+ +[^ ]"
TIMETRACK_PATTERN+="|\bthemis\b"
TIMETRACK_PATTERN+="|\btime\b"
TIMETRACK_PATTERN+="|\btokei\b"
TIMETRACK_PATTERN+="|\bzsh:plugins:update\b"
TIMETRACK_PATTERN+="|\bwebpack\b"
TIMETRACK_PATTERN+="|\byarn\b"
TIMETRACK_PATTERN+="|\byum\b"
TIMETRACK_PATTERN+="|\bzcat\b"
TIMETRACK_PATTERN+="|\bzip\b"
TIMETRACK_PATTERN+="|\.z?sh\b"

export TIMETRACK_IGNORE_PATTERN
export TIMETRACK_PATTERN

# Inspired by http://qiita.com/hayamiz/items/d64730b61b7918fbb970
# Don’t load followings lazily because zsh doesn’t track some commands, e.g., `exec zsh`

autoload -U add-zsh-hook

function timetrack:start {
  local command="${1:?}"

  export __TIMETRACK_STARTED_AT="$(date +%s)"
  export __TIMETRACK_COMMAND="${command}"
}

function timetrack:finish {
  local last_status="$?"
  local finished_at="$(date +%s)"

  if [ -z "${__TIMETRACK_STARTED_AT}" ] || [ -z "${__TIMETRACK_COMMAND}" ]; then
    return
  fi

  local started_at="${__TIMETRACK_STARTED_AT}"
  local command="${__TIMETRACK_COMMAND}"
  unset __TIMETRACK_STARTED_AT
  unset __TIMETRACK_COMMAND

  # Don’t use `[[ "${command}" =~ ${TIMETRACK_PATTERN} ]]` because it doesn’t work on Mac
  if echo "${command}" | grep -E -v "${TIMETRACK_IGNORE_PATTERN}" | grep -E -q "${TIMETRACK_PATTERN}"; then
    local exec_time=$((finished_at - started_at))

    if [ "${last_status}" = "0" ]; then
      local result="Command succeeded!!"
      local title="👼 ${result}"
    else
      local result="Command failed!!"
      local title="👿 ${result}"
    fi

    title+=" (${exec_time} seconds)"
    local notifier_options=(--title "${title}")
    local message="Command: ${command}"

    local long_run_threshold_seconds=30

    if ((exec_time < long_run_threshold_seconds)); then
      notifier_options+=(--nostay)
    fi

    # Sometimes `async_*` aren’t available, e.g., just after `exec zsh`.
    if command -v async_stop_worker > /dev/null; then
      local notifier_args="$(printf "%q " "${message}" "${notifier_options[@]}")"
      async_stop_worker  "TIMETRACK_NOTIFIER_$$" 2> /dev/null
      async_start_worker "TIMETRACK_NOTIFIER_$$"
      async_job          "TIMETRACK_NOTIFIER_$$" "notify ${notifier_args}"
    else
      notify "${message}" "${notifier_options[@]}"
    fi

    if [ "${last_status}" = "0" ]; then
      title="${title//${result}/$(highlight:green "${result}")}"
    else
      title="${title//${result}/$(highlight:red "${result}")}"
    fi

    if ((exec_time >= long_run_threshold_seconds)); then
      title="${title//${exec_time} seconds/$(highlight:yellow "${exec_time} seconds")}"
    fi

    printf "\n* * *\n%s\n%s\n" "${title}" "${message}"
  fi
}

add-zsh-hook preexec timetrack:start
add-zsh-hook precmd timetrack:finish
