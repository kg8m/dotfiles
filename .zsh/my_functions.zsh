function execute_with_echo {
  printf "\n\e[0;36mExecute:\e[1;37m \`%s\`\n\n" "$*" >&2
  eval "$@"
}

function execute_commands_with_echo {
  local cmd
  local result=0

  for cmd in "$@"; do
    execute_with_echo "$cmd" || result=$?
  done

  return "$result"
}

function execute_with_confirm {
  local response

  printf "\n\e[0;36mExecute:\e[1;37m \`%s\`\n\n" "$*"
  read -r "response?Are you sure? [y/n]: "

  if [[ ${response} =~ ^y ]]; then
    export __execute_with_confirm_executed="1"
    eval "$@"
  else
    export __execute_with_confirm_executed=""
    echo "Canceled."
  fi
}

function retriable_execute_with_confirm {
  execute_with_confirm "$@"
  local result=$?

  if [ "$__execute_with_confirm_executed" = "1" ]; then
    local response

    echo
    [ "$result" = "0" ] && echo "👼 Succeeded." || echo "👿 Failed."
    echo
    read -r "response?Retry? [y/n]: "

    if [[ "$response" =~ ^y ]]; then
      retriable_execute_with_confirm "$@"
    fi
  fi
}

function notify {
  local options=("${(M)@:#-*}")
  local non_options=("${@:#-*}")
  local message="[$(hostname)] ${non_options:-Command finished.}"

  local notifier_options=("-group \"NOTIFY_${message}\"")

  if [ "${options[(I)--nostay]}" = "0" ]; then
    notifier_options+=("-sender TERMINAL_NOTIFIER_STAY")
  fi

  # `> /dev/null` for ignoring "Removing previously sent notification" message
  ssh main -t "echo '${message}' | /usr/local/bin/terminal-notifier ${notifier_options[*]}" > /dev/null
}

function batch_move {
  local response

  zmv -n "$@" | less
  read -r "response?Execute? [y/n]: "

  if [[ "$response" =~ ^y ]]; then
    zmv "$@"
  else
    echo "Canceled."
  fi
}
alias bmv="batch_move"

function trash {
  local source
  local filename
  local new_filename
  local timestamp=$(date +%H.%M.%S)
  local trash_path=${TRASH_PATH:-/tmp}

  for source in "$@"; do
    filename=$(basename "$source")

    if [ -f "$trash_path/$filename" ] || [ -d "$trash_path/$filename" ]; then
      sed_expr='s/^\(\.\?[^.]\+\)\(\.\?\)/\1 '"$timestamp.${RANDOM}"'\2/'
      new_filename=$(echo "$filename" | sed -e "$sed_expr")
    else
      new_filename="$filename"
    fi

    touch "$source"
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
  if [ -n "$1" ]; then
    local session_name="$1"
  else
    local session_name=default
  fi

  if ! tmux has-session -t "$session_name" > /dev/null 2>&1; then
    local response
    read -r "response?Create new session in directory \`$PWD\` with session name \`$session_name\`? [y/n]:"

    if [[ "$response" =~ ^y ]]; then
      if [ "$session_name" = "default" ]; then
        tmux_setup_default
      else
        tmux new-session -d -s "$session_name"

        if [ -n "$2" ]; then
          tmux send-keys -t "$session_name":1 "$2" Enter
        fi
      fi
    else
      echo "Session not created."
    fi
  fi

  tmux attach -t "$session_name"
}

# Never use tmuxinator
alias mux="attach_or_new_tmux"

# http://d.hatena.ne.jp/itchyny/20130227/1361933011
function extract() {
  case "$1" in
    *.tar.gz | *.tgz) tar xzvf "$1" ;;
    *.tar.xz) tar Jxvf "$1" ;;
    *.zip) unzip "$1" ;;
    *.lzh) lha e "$1" ;;
    *.tar.bz2 | *.tbz) tar xjvf "$1" ;;
    *.tar.Z) tar zxvf "$1" ;;
    *.gz) gzip -dc "$1" ;;
    *.bz2) bzip2 -dc "$1" ;;
    *.Z) uncompress "$1" ;;
    *.tar) tar xvf "$1" ;;
    *.arj) unarj "$1" ;;
    *.zst | *.zstd) unzstd "$1" ;;
  esac
}
# shellcheck disable=SC2139
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz,zst,zstd}=extract

function my_grep() {
  local args

  if [ -n "${RIPGREP_EXTRA_OPTIONS:-}" ]; then
    # Split $RIPGREP_EXTRA_OPTIONS by whitespaces
    args=("${=RIPGREP_EXTRA_OPTIONS}" "$@")
  else
    args=("$@")
  fi

  rg "${args[@]}"
}

function my_grep_with_filter() {
  local options=()
  local non_options=()
  local is_waiting_option_value=false
  local arg

  for arg in "$@"; do
    if [[ "$arg" =~ ^-- ]]; then
      is_waiting_option_value=false
      options+=("$arg")

      if [[ ! "$arg" =~ = ]]; then
        is_waiting_option_value=true
      fi
    elif [[ "$arg" =~ ^- ]]; then
      is_waiting_option_value=false
      options+=("$arg")

      if [[ "$arg" =~ ^-.$ ]]; then
        is_waiting_option_value=true
      fi
    else
      if "$is_waiting_option_value"; then
        is_waiting_option_value=false
        options+=("$arg")
      else
        non_options+=("$arg")
      fi
    fi
  done

  local query="${non_options[1]}"
  local results=("${(@f)$(
    my_grep --column --line-number --no-heading --color=always --with-filename "$@" 2> /dev/null |
      filter --header="Grep: '$query'" --delimiter=":" --preview-window="right:50%:wrap:nohidden:+{2}-/2" --preview="$FZF_VIM_PATH/bin/preview.sh {}"
  )}")

  if [ -z "${results[*]}" ]; then
    return
  fi

  echo "${(j:\n:)results[@]}" | my_grep "$query" "${options[@]}" 2> /dev/null

  # Check whether the output is on a terminal
  if [ -t 1 ]; then
    local response

    echo
    read -r "response?Open found files? [y/n]: "

    if [[ "$response" =~ ^y ]]; then
      local filepaths=("${(@f)$(echo "${(j:\n:)results[@]}" | grep -E ':[0-9]+:[0-9]+:' | grep -E -o '^[^:]+' | sort -u)}")

      # Don't use literal `vim` because it sometimes refers to wrong Vim
      eval "vim ${filepaths[*]}"
    fi
  fi
}
alias gr="my_grep_with_filter"

function tig {
  case "$1" in
    bl*)
      shift
      execute_with_echo "command tig blame $*"
      ;;
    stash)
      execute_with_echo "command tig stash"
      ;;
    st*)
      execute_with_echo "command tig status"
      ;;
    *)
      execute_with_echo "command tig $*"
      ;;
  esac
}

function update_zsh_plugins {
  trash "${KGYM_ZSH_CACHE_DIR:-}"
  mkdir -p "$KGYM_ZSH_CACHE_DIR"

  execute_with_echo "compile_zshrcs:cleanup"

  execute_with_echo "zinit self-update"
  notify --nostay "Executing \`zinit delete --clean\`, so allow to continue"
  execute_with_echo "zinit delete --clean"
  execute_with_echo "zinit cclear"
  execute_with_echo "find ${ZINIT[SNIPPETS_DIR]:-} -type d -empty -delete"

  local current_dir="$PWD"

  # Clean up the directory because enhancd makes it dirty when loaded
  execute_with_echo "cd ${ENHANCD_ROOT:-}"
  execute_with_echo "git restore ."
  execute_with_echo "cd $current_dir"

  execute_with_echo "zinit update --all --parallel --quiet"

  # Execute `init.sh` to delete files fo fish because they are treated as completions by zinit
  execute_with_echo "cd ${ENHANCD_ROOT:-}"
  execute_with_echo "source init.sh"
  execute_with_echo "cd $current_dir"

  execute_with_echo "zinit creinstall ${ZINIT[BIN_DIR]}"
  execute_with_echo "zinit csearch"

  execute_with_echo "compile_zshrcs:run"

  execute_with_echo "exec zsh"
}

function compile_zshrcs:run {
  local zshrc
  for zshrc in ~/.zshrc* ~/.zsh/*.zsh; do
    if [ -f "$zshrc" ] && ! [[ "$zshrc" =~ \.zwc$ ]]; then
      zcompile "$zshrc"
    fi
  done
}

function compile_zshrcs:cleanup {
  local zwc
  for zwc in ~/.zshrc*.zwc ~/.zsh/*.zsh.zwc; do
    if [ -f "$zwc" ]; then
      rm -f "$zwc"
    fi
  done
}

function uninstall_go_library {
  local library="$1"
  local libpaths=("${(@f)$(find ~/go "${GOENV_ROOT:-}" -maxdepth 5 -path "*${library}*")}")

  if [ -z "${libpaths[*]}" ]; then
    echo "No library files/directories found for ${library}."
    return 1
  fi

  # shellcheck disable=SC2145
  echo -e "${(j:\n:)libpaths[@]}\n"

  local response
  read -r "response?Remove found files/directories? [y/n]: "

  if [[ "$response" =~ ^y ]]; then
    echo "${(j:\n:)libpaths[@]}" | while read -r libpath; do
      trash "$libpath"
    done
  else
    echo "Canceled."
  fi
}
