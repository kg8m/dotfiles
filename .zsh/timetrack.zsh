# http://qiita.com/hayamiz/items/d64730b61b7918fbb970
return
autoload -U add-zsh-hook 2>/dev/null || return

__timetrack_threshold=10  # seconds
read -r -d '' __timetrack_target_commands <<EOF
ruby
ruby_multitest
rake
rake_units
rake_functionals
rake_integration
frake_units
frake_functionals
frake_integration
rake_models
rake_controllers
rake_helpers
prepare
migrate
mysql
mysqldump
pv
make
yum
cat
zcat
scp
rsync
EOF

# not used. it is just my note.
read -r -d '' __timetrack_ignored_commands <<EOF
svn
git
s
g
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
  local message

  export __timetrack_end=`date +%s`

  if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
    return
  fi

  for target_command in $(echo $__timetrack_target_commands); do
    if [ "$prog" = "$target_command" ]; then

      exec_time=$((__timetrack_end-__timetrack_start))
      message="[$USER@$HOST] Command finished!\nTime: $exec_time seconds\nCommand: $command"

      if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
        ssh main "echo '$message' | growlnotify -n 'ZSH timetracker' --appIcon iTerm -s"
      fi

      unset __timetrack_start
      unset __timetrack_command

      return
    fi
  done
}

add-zsh-hook preexec __my_preexec_start_timetrack
add-zsh-hook precmd __my_preexec_end_timetrack
