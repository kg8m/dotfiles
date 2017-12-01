TIMETRACK_IGNORE_PATTERN="^$"
TIMETRACK_IGNORE_PATTERN="$TIMETRACK_IGNORE_PATTERN|\b(ack|ag)\b"
TIMETRACK_IGNORE_PATTERN="$TIMETRACK_IGNORE_PATTERN|\bless\b|\bL$"
TIMETRACK_IGNORE_PATTERN="$TIMETRACK_IGNORE_PATTERN|\bvim?\b|\bV$"
TIMETRACK_IGNORE_PATTERN="$TIMETRACK_IGNORE_PATTERN|\b(viack|viag)\b"
TIMETRACK_PATTERN="^$"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\b(bin/|bundle exec )?rails r"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\b(bin/|bundle exec )?rails t"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\b(bin/|bundle exec )?rake\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\b(bundle exec )?r?spec\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\b(bundle exec )?ruby\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bbrew\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bcat\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bfor\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bmake\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bmysql .*( -e|<)"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bmysqldump\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bpv\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\brsync\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bscp\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bssh +[a-z0-9_.@]+ +['\"]"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\btime\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\byum\b"
TIMETRACK_PATTERN="$TIMETRACK_PATTERN|\bzcat\b"

# inspired by http://qiita.com/hayamiz/items/d64730b61b7918fbb970
autoload -U add-zsh-hook 2>/dev/null || return

# seconds
__timetrack_long_threshold=30
__timetrack_short_threshold=15

export __timetrack_long_threshold
export __timetrack_short_threshold

function __my_preexec_start_timetrack() {
  local command=$1

  export __timetrack_start=$( date +%s )
  export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
  local exec_time
  local message
  local command=$( echo $__timetrack_command | sed -e "s/'/'\\\\''/g" )
  local growl_options="-n 'ZSH timetracker' --appIcon iTerm"
  local notify=false

  export __timetrack_end=`date +%s`

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_long_threshold" ] || [ -z "$__timetrack_short_threshold" ]; then
    return
  fi

  if ! [ "$command" =~ $TIMETRACK_IGNORE_PATTERN ] && [ "$command" =~ $TIMETRACK_PATTERN ]; then
    exec_time=$(( __timetrack_end - __timetrack_start ))
    message="Command finished!!\nTime: $exec_time seconds\nCommand: $command"

    if [ "$exec_time" -ge "$__timetrack_long_threshold" ]; then
      growl_options="$growl_options -s"
      notify=true
    elif [ "$exec_time" -ge "$__timetrack_short_threshold" ]; then
      notify=true
    fi

    if $notify; then
      ssh main "echo '[$USER@$HOST] $message' | growlnotify $growl_options"
      echo "\n* * *"
      echo $message
      echo "Notified by \`growlnotify $growl_options\`"
    fi

    unset __timetrack_start
    unset __timetrack_command

    return
  fi
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
