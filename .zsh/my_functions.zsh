function execute_with_echo {
  cmd_with_arguments=$@;

  echo "----- ${cmd_with_arguments} ---------------";
  eval ${cmd_with_arguments};
}

function execute_commands_with_echo {
  for command in $@; do
    execute_with_echo $command
    echo
  done
}

function migrate {
  if (($# == 1)) then
    cmd="rake db:migrate VERSION=$1";
  else
    cmd="rake db:migrate";
  fi

  execute_with_echo ${cmd};
  execute_with_echo "rake db:test:load_structure";
}

function mysql_current {
  base_dirname='branch'
  dirname=`basename \`pwd\``

  if [ "${dirname}" = "${base_dirname}" ]; then
    dbname="${APP_NAME}"
  else
    dbname="${APP_NAME}_${dirname}"
  fi

  execute_with_echo "mysql -u root ${dbname} $@";
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
  if (($# == 0)); then
    session_name='default'
  else
    session_name=$1
  fi

  tmux has-session -t $session_name &> /dev/null

  if [ $? != 0 ]; then
    read 'response?Create new session in directory `'$( pwd )'` with session name `'$( echo $session_name )'`? [y/n]: '

    if [[ $response =~ ^y ]]; then
      if [ $session_name = 'default' ]; then
        tmux_setup_default
      else
        tmux new-session -d -s $session_name

        if (($# == 2)); then
          tmux send-keys -t $session_name:1 "$2" Enter
        fi
      fi
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

function color_pallet() {
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;${c};48;05;000m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;255;48;05;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
  execute_with_echo 'for c in {000..255}; do echo -n "\e[38;05;000;48;05;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo; done; echo "\e[38;05;255;48;05;000m"'
}

function viack() {
  vi `ack $@ -l`
}
