TIMETRACK_IGNORE_PATTERN="^$"
TIMETRACK_IGNORE_PATTERN+="|^man "
TIMETRACK_IGNORE_PATTERN+="|\bNO_TIMETRACK\b"
TIMETRACK_IGNORE_PATTERN+="|\bgit (add|bulk|ca|checkout|ci|co\b|commit\b|d|l|mergetool|open-changed-files|rebase -i|restore|revert|show|st|sw)"
TIMETRACK_IGNORE_PATTERN+="|\bless\b|\bL$"
TIMETRACK_IGNORE_PATTERN+="|\bmy_grep_with_filter\b"
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
TIMETRACK_PATTERN+="|\berblint\b"
TIMETRACK_PATTERN+="|\bfind\b"
TIMETRACK_PATTERN+="|\bfor\b"
TIMETRACK_PATTERN+="|\bgit\b"
TIMETRACK_PATTERN+="|\bgo\b"
TIMETRACK_PATTERN+="|\bhyperfine\b"
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
TIMETRACK_PATTERN+="|\bthemis\b"
TIMETRACK_PATTERN+="|\btime\b"
TIMETRACK_PATTERN+="|\bupdate_zsh_plugins\b"
TIMETRACK_PATTERN+="|\bwebpack\b"
TIMETRACK_PATTERN+="|\byarn\b"
TIMETRACK_PATTERN+="|\byum\b"
TIMETRACK_PATTERN+="|\bzcat\b"
TIMETRACK_PATTERN+="|\bzip\b"
TIMETRACK_PATTERN+="|\.z?sh$"

export TIMETRACK_IGNORE_PATTERN
export TIMETRACK_PATTERN

# inspired by http://qiita.com/hayamiz/items/d64730b61b7918fbb970
# Don't load followings lazily because zsh doesn't track some commands, e.g., `exec zsh`

autoload -U add-zsh-hook

__timetrack_threshold=30

export __timetrack_threshold

function __my_preexec_start_timetrack() {
  local command=$1

  export __timetrack_start=$(date +%s)
  export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
  local last_status=$?
  local exec_time result title message
  local command="${__timetrack_command//'/'\\''}"
  local notifier_options=(-group "TIMETRACK_${USER}@${HOST}_$(printf %q "$command")")

  export __timetrack_end="$(date +%s)"

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
    return
  fi

  # Don't use `[[ "$command" =~ $TIMETRACK_PATTERN ]]` because it doesn't work on Mac
  if echo "$command" | grep -E -v "$TIMETRACK_IGNORE_PATTERN" | grep -E -q "$TIMETRACK_PATTERN"; then
    exec_time=$((__timetrack_end - __timetrack_start))

    if [ "$last_status" = "0" ]; then
      result="Command succeeded!!"
      title="👼 ${result}"
    else
      result="Command failed!!"
      title="👿 ${result}"
    fi

    title+=" ($exec_time seconds)"
    notifier_options+=(-title "$(printf %q "$title")")
    message="Command: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      notifier_options+=(-sender TERMINAL_NOTIFIER_STAY)
    fi

    # `> /dev/null` for ignoring "Removing previously sent notification" message.
    # Throwing stderr away for ignoring "Connection to * closed." message.
    ssh main -t "echo '[$(hostname)] $message' | /usr/local/bin/terminal-notifier ${notifier_options[*]}" > /dev/null 2>&1

    if [ "$last_status" = "0" ]; then
      title="${title//${result}/$(highlight:green "$result")}"
    else
      title="${title//${result}/$(highlight:red "$result")}"
    fi

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      title="${title//${exec_time} seconds/$(highlight:yellow "${exec_time} seconds")}"
    fi

    printf "\n* * *\n"
    echo "$title"
    echo "$message"

    unset __timetrack_start
    unset __timetrack_command

    return
  fi
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
