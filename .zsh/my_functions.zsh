function execute_with_echo {
  local cmd_with_arguments=$@;

  echo "----- ${cmd_with_arguments} ---------------";
  eval ${cmd_with_arguments};
}

function execute_commands_with_echo {
  local command

  for command in $@; do
    execute_with_echo $command
    echo
  done
}

function notify {
  local message=$( printf %q "[$USER@$HOST] ${@:-Command finished.}" )
  ssh main "growlnotify -m $message -a iTerm -s"
}

function migrate {
  local cmd

  if (($# == 1)) then
    cmd="rake db:migrate VERSION=$1";
  else
    cmd="rake db:migrate";
  fi

  execute_with_echo ${cmd};
  execute_with_echo "rake db:test:load_structure";
}

function tmux_setup_default {
  tmux new-session -d -s default
  tmux new-window -t default:2
  tmux new-window -t default:3
  tmux new-window -t default:4

  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux select-layout -t default:1 even-horizontal

  tmux split-window -h -t default:2
  tmux select-layout -t default:2 main-vertical

  tmux select-window -t default:2
  tmux attach-session -t default
}

function attach_or_new_tmux {
  local session_name
  local response

  if (($# == 0)); then
    session_name='default'
  else
    session_name=$1
  fi

  tmux has-session -t $session_name &> /dev/null

  if [ $? != 0 ]; then
    read 'response?Create new session in directory `'$( pwd )'` with session name `'$session_name'`? [y/n]: '

    if [[ $response =~ ^y ]]; then
      read 'response?Resotre tmux environment for `'$session_name'` session if available? [y/n]: '

      if [[ ! $response =~ ^y ]]; then
        touch ~/tmux_no_auto_restore
      fi

      if [ $session_name = 'default' ]; then
        tmux_setup_default
      else
        tmux new-session -d -s $session_name

        if (($# == 2)); then
          tmux send-keys -t $session_name:1 "$2" Enter
        fi
      fi

      rm -f ~/tmux_no_auto_restore
    else
      echo 'Not created.'
    fi
  fi

  tmux attach -t $session_name
}

# http://d.hatena.ne.jp/itchyny/20130227/1361933011
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -dc $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

function viag() {
  vi `ag $@ -l`
}

function viack() {
  vi `ack $@ -l`
}
