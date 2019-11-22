function execute_with_echo {
  echo -e "\\n\\e[0;36mExecute:\\e[1;37m \`$@\`\\n" >&2
  eval $@
}

function execute_commands_with_echo {
  local cmd

  for cmd in $@; do
    execute_with_echo $cmd
  done
}

function execute_with_confirm {
  echo -e "\\n\\e[0;36mExecute:\\e[1;37m \`$@\`\\n"
  read "response?Are you sure? [y/n]: "

  if [[ ${response} =~ ^y ]]; then
    export __execute_with_confirm_executed="1"
    eval $@
  else
    export __execute_with_confirm_executed=""
    echo "Canceled."
  fi
}

function retriable_execute_with_confirm {
  execute_with_confirm "$@"
  local result=$?

  if [[ "$__execute_with_confirm_executed" = "1" ]]; then
    echo
    [[ $result = 0 ]] && echo "👼 Succeeded." || echo "👿 Failed."
    echo
    read "response?Retry? [y/n]: "

    if [[ ${response} =~ ^y ]]; then
      retriable_execute_with_confirm $@
    fi
  fi
}

function notify {
  local message=$( printf %q "[$USER@$HOST] ${@:-Command finished.}" )
  ssh main "growlnotify -m $message -a iTerm -s"
}

function batch_move {
  zmv -n $@ | less
  read 'response?Execute? [y/n]: '

  if [[ $response =~ ^y ]]; then
    zmv $@
  else
    echo "Canceled."
  fi
}
alias bmv="batch_move"

function trash {
  local filename
  local new_filename
  local timestamp=$( date +%H.%M.%S )
  local trash_path=${TRASH_PATH-/tmp}

  for source in $@; do
    filename=$( basename $( echo $source ) )

    if [ -f $trash_path/$filename ] || [ -d $trash_path/$filename ]; then
      sed_expr='s/^\([^.]\+\)\./\1 '$timestamp'./'
      new_filename=$( echo $filename | sed -e $sed_expr )
    else
      new_filename=$filename
    fi

    touch $source
    execute_with_echo "mv -i '$source' '$trash_path/$new_filename'"
  done
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
    local session_name=default
  else
    local session_name=$1
  fi

  tmux has-session -t $session_name &> /dev/null

  if [ $? != 0 ]; then
    local response
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
    *.zst|*.zstd) unzstd $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz,zst,zstd}=extract

function rg_without_pager() {
  command rg $@
}

function rg_with_pager() {
  # Enable colors, group by filepath, and show line numbers
  rg_without_pager --pretty $@ | less
}
alias rg="rg_with_pager"

function rg_for_grep() {
  command rg --color never --files-with-matches $@
}

function vig() {
  vi $( rg_for_grep $@ )
}
