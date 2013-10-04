# http://qiita.com/hayamiz/items/d64730b61b7918fbb970

autoload -U add-zsh-hook 2>/dev/null || return

__timetrack_threshold=10  # seconds
read -r -d '' __timetrack_target_commands <<EOF
ruby
rake
make
EOF

export __timetrack_threshold
export __timetrack_target_commands

function __my_preexec_start_timetrack() {
  local command=$1

  export __timetrack_start=`date +%s`
  export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
  local exec_time
  local command=$__timetrack_command
  local prog=$(echo $command|awk '{print $1}')
  local notify_method
  local message

  export __timetrack_end=`date +%s`

  if test -n "${REMOTEHOST}${SSH_CONNECTION}"; then
    notify_method="remotehost"
  elif which growlnotify >/dev/null 2>&1; then
    notify_method="growlnotify"
  elif which notify-send >/dev/null 2>&1; then
    notify_method="notify-send"
  else
    return
  fi

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
    return
  fi

  for target_command in $(echo $__timetrack_target_commands); do
    [ "$prog" = "$target_command" ]

    exec_time=$((__timetrack_end-__timetrack_start))
    if [ -z "$command" ]; then
      command="<UNKNOWN>"
    fi

    message="[$USER@$HOST] Command finished!\nTime: $exec_time seconds\nCOMMAND: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
      ssh main "echo '$message' | growlnotify -n 'ZSH timetracker' --appIcon iTerm -s"
    fi

    unset __timetrack_start
    unset __timetrack_command

    return
  done
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
