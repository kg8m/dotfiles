TIMETRACK_PATTERN="^$"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *(bin/|bundle exec )?rails r"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *(bin/|bundle exec )?rake\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *(bundle exec )?r?spec\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *(bundle exec )?ruby\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *brew\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *cat\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *for\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *make\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *mysql .*( -e|<)"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *mysqldump\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *pv\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *rsync\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *scp\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *ssh +[a-z0-9_.@]+ +['\"]"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *time\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *yum\\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|^ *zcat\\b"

# inspired by http://qiita.com/hayamiz/items/d64730b61b7918fbb970
autoload -U add-zsh-hook 2>/dev/null || return

__timetrack_threshold=30  # seconds

export __timetrack_threshold

function __my_preexec_start_timetrack() {
  local command=$1

  export __timetrack_start=`date +%s`
  export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
  local exec_time
  local command=$( echo $__timetrack_command | sed -e "s/'/'\\\\''/g" )
  local message

  export __timetrack_end=`date +%s`

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
    return
  fi

  if [ "$command" =~ $TIMETRACK_PATTERN ]; then
    exec_time=$((__timetrack_end-__timetrack_start))
    message="Command finished!!\nTime: $exec_time seconds\nCommand: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      ssh main "echo '[$USER@$HOST] $message' | growlnotify -n 'ZSH timetracker' --appIcon iTerm -s"
      echo $message
    fi

    unset __timetrack_start
    unset __timetrack_command

    return
  fi
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
