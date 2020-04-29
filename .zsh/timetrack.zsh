TIMETRACK_IGNORE_PATTERN="^$"
TIMETRACK_IGNORE_PATTERN+="|\bgit (add|bulk|ca|checkout|ci|co\b|commit\b|d|l|mergetool|open-changed-files|restore|revert|show|st|sw)"
TIMETRACK_IGNORE_PATTERN+="|\bless\b|\bL$"
TIMETRACK_IGNORE_PATTERN+="|\brails (c|db)"
TIMETRACK_IGNORE_PATTERN+="|\b(vim?)?(ack|ag|rg|gr)\b"
TIMETRACK_IGNORE_PATTERN+="|\bvim?\b|\bV$"
TIMETRACK_PATTERN="^$"
TIMETRACK_PATTERN+="|\b7z\b"
TIMETRACK_PATTERN+="|\bansible"
TIMETRACK_PATTERN+="|\b(bin/|bundle exec )?rails r"
TIMETRACK_PATTERN+="|\b(bin/|bundle exec )?rails t"
TIMETRACK_PATTERN+="|\b(bin/|bundle exec )?rake\b"
TIMETRACK_PATTERN+="|\b(bundle exec )?r?spec\b"
TIMETRACK_PATTERN+="|\b(bundle exec )?ruby\b"
TIMETRACK_PATTERN+="|\bbrew\b"
TIMETRACK_PATTERN+="|\bcat\b"
TIMETRACK_PATTERN+="|\bconfigure\b"
TIMETRACK_PATTERN+="|\bfor\b"
TIMETRACK_PATTERN+="|\bgo\b"
TIMETRACK_PATTERN+="|\bmake\b"
TIMETRACK_PATTERN+="|\bmysql .*( -e|<)"
TIMETRACK_PATTERN+="|\bmysqldump\b"
TIMETRACK_PATTERN+="|\bpv\b"
TIMETRACK_PATTERN+="|\b(rails|rake) stats\b"
TIMETRACK_PATTERN+="|\brbenv\b"
TIMETRACK_PATTERN+="|\brsync\b"
TIMETRACK_PATTERN+="|\brubocop(-daemon)?\b"
TIMETRACK_PATTERN+="|\bscp\b"
TIMETRACK_PATTERN+="|\bssh +[a-z0-9_.@]+ +['\"]"
TIMETRACK_PATTERN+="|\btime\b"
TIMETRACK_PATTERN+="|\bupdate_zsh_plugins\b"
TIMETRACK_PATTERN+="|\bwebpack\b"
TIMETRACK_PATTERN+="|\byarn\b"
TIMETRACK_PATTERN+="|\byum\b"
TIMETRACK_PATTERN+="|\bzcat\b"
TIMETRACK_PATTERN+="|\bzip\b"
TIMETRACK_PATTERN+="|\.z?sh$"
TIMETRACK_PATTERN+="|^git "

export TIMETRACK_IGNORE_PATTERN
export TIMETRACK_PATTERN

# inspired by http://qiita.com/hayamiz/items/d64730b61b7918fbb970
autoload -U add-zsh-hook 2>/dev/null || return

# seconds
__timetrack_threshold=30

export __timetrack_threshold

function __my_preexec_start_timetrack() {
  local command=$1

  export __timetrack_start=$( date +%s )
  export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
  local last_status=$?
  local exec_time
  local title
  local message
  local command="${__timetrack_command//'/'\\''}"
  local notifier_options="-group \"TIMETRACK_${USER}@${HOST}_$( printf '%q' "$command" )\""

  export __timetrack_end="$( date +%s )"

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
    return
  fi

  # Don't use `[ "$command" =~ $TIMETRACK_PATTERN ]` because it doesn't work on Mac
  if echo "$command" | egrep -v "$TIMETRACK_IGNORE_PATTERN" | egrep -q "$TIMETRACK_PATTERN"; then
    exec_time=$(( __timetrack_end - __timetrack_start ))

    if [ "$last_status" = "0" ]; then
      title='👼 Command succeeded!!'
    else
      title='👿 Command failed!!'
    fi

    title+=" ($exec_time seconds)"
    notifier_options+=" -title '$title'"
    message="Command: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      notifier_options="$notifier_options -sender TERMINAL_NOTIFIER_STAY"
    fi

    # `> /dev/null` for ignoring "Removing previously sent notification" message
    ssh main -t "echo '[$USER@$HOST] $message' | /usr/local/bin/terminal-notifier $notifier_options" > /dev/null

    if [ "$last_status" = "0" ]; then
      message="${message//Command succeeded!!/\e[0;32mCommand succeeded!!\e[1;37m}"
    else
      message="${message//Command failed!!/\e[0;31mCommand failed!!\e[1;37m}"
    fi

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      message="${message//${exec_time} seconds/\e[1;33m${exec_time} seconds\e[1;37m}"
    fi

    printf "\n* * *\n"
    echo "$message"
    echo "Notified by \`terminal-notifier $notifier_options\`"
    date

    unset __timetrack_start
    unset __timetrack_command

    return
  fi
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
