function execute_with_echo {
  # shellcheck disable=SC2198
  if [ ! "${@[(I)--dryrun]}" = "0" ]; then
    local dryrun="1"
  fi

  local cmd=("${(R)@:#--dryrun}")

  if [ -z "${cmd[*]}" ]; then
    echo:warn "Specify command."
    return 1
  fi

  printf "\n$(highlight:cyan "Execute%s:")\e[0;1m \`%s\`\e[0m\n\n" \
    "$([ "${dryrun}" = "1" ] && echo " (dryrun)")" \
    "${cmd[*]}" >&2

  if [ ! "${dryrun}" = "1" ]; then
    eval "${cmd[*]}"
  fi
}

function execute_commands_with_echo {
  # shellcheck disable=SC2198
  if [ ! "${@[(I)-s]}" = "0" ] || [ ! "${@[(I)--separate]}" = "0" ]; then
    local separate="1"
  fi

  # shellcheck disable=SC2198
  if [ ! "${@[(I)--dryrun]}" = "0" ]; then
    local dryrun="1"
  fi

  local cmd
  local result=0

  for cmd in "${@:#-*}"; do
    if [ "${separate}" = "1" ]; then
      echo
      horizontal_line
    fi

    cmd=("${cmd}")

    if [ "${dryrun}" = "1" ]; then
      cmd+=(--dryrun)
    fi

    execute_with_echo "${cmd[@]}" || result=$?
  done

  if [ "${separate}" = "1" ]; then
    echo
    horizontal_line
  fi

  return "${result}"
}

function execute_with_confirm {
  if [ -z "$*" ]; then
    echo:warn "Specify command."
    return 1
  fi

  local response

  printf "\n$(highlight:cyan "Execute:")\e[0;1m \`%s\`\e[0m\n\n" "$*" >&2
  read -r "response?Are you sure? [y/n]: "

  if [[ ${response} =~ ^y ]]; then
    eval "$*"
  else
    echo "Canceled." >&2
    return 255
  fi
}

function retriable_execute_with_confirm {
  execute_with_confirm "$@"
  local result=$?

  if [ ! "${result}" = "255" ]; then
    local message response

    if [ "${result}" = "0" ]; then
      message="👼 Succeeded."
    else
      message="👿 Failed."
    fi

    printf "\n%s\n\n" "${message}" >&2
    read -r "response?Retry? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      retriable_execute_with_confirm "$@"
    fi
  fi
}

function horizontal_line {
  echo "\e[38;5;239m${(r:${COLUMNS}::-:)}\e[0m"
}

function highlight:red {
  highlight:base "1" "$@"
}

function highlight:green {
  highlight:base "2" "$@"
}

function highlight:yellow {
  highlight:base "3" "$@"
}

function highlight:magenta {
  highlight:base "5" "$@"
}

function highlight:cyan {
  highlight:base "6" "$@"
}

function highlight:gray {
  highlight:base "245" "$@"
}

function highlight:base {
  local color="${1:?}"
  shift 1

  local style="1"
  local args=()

  local arg
  for arg in "$@"; do
    case "${arg}" in
      --no-bold | --nobold)
        style="0"
        ;;
      *)
        args+=("${arg}")
        ;;
    esac

    shift 1
  done

  printf "\e[%d;38;5;%dm%s\e[0;0m" "${style}" "${color}" "${args[*]}"
}

function echo:error {
  printf "%s\n" "$(highlight:red "ERROR -- $*")" >&2
}

function echo:warn {
  printf "%s\n" "$(highlight:yellow "WARN -- $*")" >&2
}

function echo:info {
  printf "%s\n" "$(highlight:cyan "INFO -- $*" --nobold)" >&2
}

# cf. `man zshcontrib` for `zmv`
function batch_move {
  local dryrun_result=("${(@f)$(zmv -n "$@")}")

  if [ -z "${dryrun_result[*]}" ]; then
    return 1
  fi

  echo "${(j:\n:)dryrun_result[@]}" | less

  local response
  read -r "response?Execute? [y/n]: "

  if [[ "${response}" =~ ^y ]]; then
    zmv "$@"
  else
    echo:info "Canceled."
  fi
}

function trash {
  local source filename new_filename
  local timestamp=$(date +%H.%M.%S)
  local trash_path=${TRASH_PATH:-/tmp}

  for source in "$@"; do
    filename=$(basename "${source}")

    if [ -f "${trash_path}/${filename}" ] || [ -d "${trash_path}/${filename}" ]; then
      # foo         => foo 12.34.56.7890
      # foo.bar     => foo 12.34.56.7890.bar
      # foo.bar.baz => foo 12.34.56.7890.bar.baz
      sed_expr='s/^\(\.\?[^.]\+\)\(\.\?\)/\1 '"${timestamp}.${RANDOM}"'\2/'
      new_filename=$(echo "${filename}" | sed -e "${sed_expr}")
    else
      new_filename="${filename}"
    fi

    touch "${source}"
    execute_with_echo "mv '${source}' '${trash_path}/${new_filename}'"
  done
}

function remove_symlink {
  local filepath="${1:?}"

  if [ -L "${filepath}" ]; then
    rm "${filepath}"
  else
    echo:warn "${filepath} is not a symbolic link."
  fi
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
  local session_name="${1:-default}"

  if ! tmux has-session -t "${session_name}" > /dev/null 2>&1; then
    local response
    read -r "response?Create new session in directory \`${PWD}\` with session name \`${session_name}\`? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      if [ "${session_name}" = "default" ]; then
        tmux_setup_default
      else
        tmux new-session -d -s "${session_name}"

        if [ -n "$2" ]; then
          tmux send-keys -t "${session_name}":1 "$2" Enter
        fi
      fi
    else
      echo:warn "Session not created."
    fi
  fi

  tmux attach -t "${session_name}"
}

# http://d.hatena.ne.jp/itchyny/20130227/1361933011
function extract {
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

function my_grep {
  local args

  if [ -n "${RIPGREP_EXTRA_OPTIONS:-}" ]; then
    args=("${=RIPGREP_EXTRA_OPTIONS}" "$@")
  else
    args=("$@")
  fi

  rg "${args[@]}"
}

# cf. Vim's kg8m#util#grep#build_qflist_from_buffer()
function my_grep_with_filter {
  local query="${1:?}"
  shift 1

  local options=()
  local non_options=()

  while [ "${#@}" -gt 0 ]; do
    case "$1" in
      --*)
        options+=("$1")

        if ! [[ "$1" =~ = ]]; then
          if [ "$#" -gt 1 ]; then
            options+=("$2")
            shift 2
            continue
          fi
        fi
        ;;
      -*)
        options+=("$1")

        if [[ "$1" =~ ^-.$ ]] && [[ ! "$2" =~ ^- ]]; then
          if [ "$#" -gt 1 ]; then
            options+=("$2")
            shift 2
            continue
          fi
        fi
        ;;
      *)
        non_options+=("$1")
        ;;
    esac

    shift 1
  done

  local grep_args=(
    "${query}"
    --column
    --line-number
    --no-heading
    --color always
    --with-filename
  )
  local filter_args=(
    --header "Grep: ${query} ${options[*]} ${non_options[*]}"
    --delimiter ":"
    --preview "preview {}"
    --preview-window "down:75%:wrap:nohidden:+{2}-/2"
  )

  if [ -n "${options[*]}" ]; then
    grep_args+=("${options[@]}")
  fi

  if [ -n "${non_options[*]}" ]; then
    grep_args+=("${non_options[@]}")
  fi

  local results=("${(@f)$(my_grep "${grep_args[@]}" | filter "${filter_args[@]}")}")

  if [ -z "${results[*]}" ]; then
    return
  fi

  if [ "${options[(I)--files]}" = "0" ]; then
    echo "${(j:\n:)results[@]}" | my_grep "${query}" "${options[@]}" 2> /dev/null
  else
    echo "${(j:\n:)results[@]}" 2> /dev/null
  fi

  # Check whether the output is on a terminal
  if [ -t 1 ]; then
    local response

    echo >&2
    read -r "response?Open found files? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      if [ "${options[(I)--files]}" = "0" ]; then
        local tempfile="$(mktemp --suffix .grep)"

        # Don't execute `echo ... | vim ... -` because current command remains as zsh if so. So tmux's
        # `pane_current_command` always returns "zsh" and automatic refreshing zsh prompt will be influenced.
        echo "${(j:\n:)results[@]}" | grep -E '^.+?:[0-9]+:[0-9]+:.' > "${tempfile}"
        execute_with_echo "vim -c 'call kg8m#util#grep#build_qflist_from_buffer()' '${tempfile}'"

        rm -f "${tempfile}"
      else
        # shellcheck disable=SC2145
        execute_with_echo "vim '${(j:' ':)results[@]}'"
      fi
    fi
  fi
}

function tig {
  mkdir -p "${XDG_DATA_HOME:?}/tig"

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

function parallel {
  local commands=("$@")

  if [ -z "${commands[*]}" ]; then
    echo:error "No commands given."
    return 1
  fi

  function parallel:log:register {
    ((PARALLEL_REGISTER_COUNT+=1))

    local message="${1:?}"
    local full_message="$(
      printf "%s%s %s" \
        "$(highlight:cyan "[Parallel]")" \
        "$(highlight:gray "$(printf "[%d/%d]" "${PARALLEL_REGISTER_COUNT}" "${PARALLEL_TOTAL_COUNT}")")" \
        "${message}"
    )"

    echo -e "${full_message}" >&2
  }

  function parallel:log:done {
    ((PARALLEL_DONE_COUNT+=1))

    local options=("${(M)@:#-*}")
    local non_options=("${(R)@:#-*}")
    local full_message="$(
      printf "%s%s %s" \
        "$(highlight:cyan "[Parallel]")" \
        "$(highlight:gray "$(printf "[%d/%d]" "${PARALLEL_DONE_COUNT}" "${PARALLEL_TOTAL_COUNT}")")" \
        "${non_options[*]}"
    )"

    echo -e "${full_message}\n" >&2

    local notify_message="$(echo "${full_message}" | remove_escape_sequences 2>/dev/null)"

    if [ "${options[(I)--notify-stay]}" = "0" ]; then
      notify --nostay "${notify_message}"
    else
      notify "${notify_message}"
    fi
  }

  function parallel:callback {
    local job_name="$1"
    local returned_code="$2"
    local stdout="$3"
    local execution_time="$4"
    local stderr="$5"

    local log_options=()

    if [ "${returned_code}" = "0" ]; then
      local result="$(highlight:green "Succeeded")"
    else
      log_options+=("--notify-stay")
      local result="$(highlight:red "Failed")"
    fi

    local log_message="$(printf "%s in %.3f: \`%s\`" "${result}" "${execution_time}" "${job_name}")"
    parallel:log:done "${log_options[@]}" "${log_message}"

    if [ -n "${stderr}" ]; then
      echo -e "${stderr}\n" >&2
    fi

    if [ -n "${stdout}" ]; then
      echo -e "${stdout}\n"
    fi

    horizontal_line

    if [ "${PARALLEL_DONE_COUNT}" = "${PARALLEL_TOTAL_COUNT}" ]; then
      echo -e "$(highlight:cyan "[Parallel]") All commands finished.\n\n" >&2
      zle .reset-prompt

      async_stop_worker "PARALLEL_WORKER"

      unset -f parallel:log:register
      unset -f parallel:log:done
      unset -f parallel:callback
    fi
  }

  export PARALLEL_TOTAL_COUNT="${#commands}"
  export PARALLEL_REGISTER_COUNT=0
  export PARALLEL_DONE_COUNT=0

  async_stop_worker       "PARALLEL_WORKER"
  async_start_worker      "PARALLEL_WORKER"
  async_register_callback "PARALLEL_WORKER" "parallel:callback"

  local command
  for command in "${commands[@]}"; do
    parallel:log:register "Execute: \`${command}\`"
    async_job "PARALLEL_WORKER" "${command}"
  done
}

function update_zsh_plugins {
  execute_with_echo "trash '${KG8M_ZSH_CACHE_DIR:?}'"
  execute_with_echo "mkdir -p '${KG8M_ZSH_CACHE_DIR}'"

  execute_with_echo "compile_zshrcs:cleanup"

  execute_with_echo "zinit self-update"
  execute_with_echo "zinit delete --clean --yes"
  execute_with_echo "zinit cclear"
  execute_with_echo "find ${ZINIT[SNIPPETS_DIR]:?} -type d -empty -delete"

  local current_dir="${PWD}"

  # Clean up the directory because enhancd makes it dirty when loaded.
  execute_with_echo "cd ${ENHANCD_ROOT:?}"
  execute_with_echo "git restore ."
  execute_with_echo "cd ${current_dir}"

  execute_with_echo "zinit update --all --parallel --quiet"

  # Remove `_*.fish` files because they are treated as completions by zinit.
  execute_with_echo "cd ${ENHANCD_ROOT:?}"
  execute_with_echo "rm -f ./**/_*.fish"
  execute_with_echo "cd ${current_dir}"

  execute_with_echo "zinit creinstall ${ZINIT[BIN_DIR]}"
  execute_with_echo "zinit csearch"

  execute_with_echo "compile_zshrcs:run"

  execute_with_echo "exec zsh"
}

function compile_zshrcs:run {
  local zshrc
  for zshrc in ~/.config/zsh/*.zsh ~/.config/zsh.local/.z* ~/.zshenv* ~/.zshrc*; do
    if [ -f "${zshrc}" ] && [[ ! "${zshrc}" =~ \.zwc$ ]]; then
      zcompile "${zshrc}"
    fi
  done
}

function compile_zshrcs:cleanup {
  local zwc
  for zwc in ~/.config/zsh/*.zsh.zwc ~/.config/zsh.local/.z*.zwc ~/.zshenv*.zwc ~/.zshrc*.zwc; do
    if [ -f "${zwc}" ]; then
      rm -f "${zwc}"
    fi
  done
}

function uninstall_go_library {
  local library="${1:?}"
  local libpaths=("${(@f)$(find ~/go "${GOENV_ROOT:?}" -maxdepth 5 -path "*${library}*")}")

  if [ -z "${libpaths[*]}" ]; then
    echo:error "No library files/directories found for ${library}."
    return 1
  fi

  # shellcheck disable=SC2145
  echo -e "${(j:\n:)libpaths[@]}\n"

  local response
  read -r "response?Remove found files/directories? [y/n]: "

  if [[ "${response}" =~ ^y ]]; then
    echo "${(j:\n:)libpaths[@]}" | while read -r libpath; do
      trash "${libpath}"
    done
  else
    echo "Canceled." >&2
  fi
}

function benchmark_vim_startup {
  local vim=${1:-vim}

  execute_with_echo "${vim} --version | awk '/^VIM - Vi IMproved/,/Features included \\(\\+\\) or not \\(-\\):$/'"
  execute_with_echo "${vim} -c 'call kg8m#plugin#recache_runtimepath() | q'"

  local base_command="vim-startuptime -count 50 -warmup 1"

  if [ ! "${vim}" = "vim" ]; then
    base_command+=" -vimpath '${vim}'"
  fi

  local arg
  local args=(
    "-Nu NONE"
    ""
    # "foo.txt"
    # "foo.md"
    # ".git/COMMIT_EDITMSG -c 'qa'"
  )

  for arg in "${args[@]}"; do
    sleep 1
    local command="${base_command}"

    if [ -n "${arg}" ]; then
      command+=" -- ${arg}"
    fi

    command+=" | head -n15"

    execute_with_echo "${command}"
  done
}

function benchmark_zsh_startup {
  execute_with_echo "compile_zshrcs:cleanup"
  execute_with_echo "compile_zshrcs:run"
  execute_with_echo "hyperfine --warmup=1 'zsh --no-rcs -i -c exit' 'zsh -i -c exit'"
}

# https://stackoverflow.com/a/28044986
function progressbar {
  local current_index="$1"
  local total_count="$2"

  if [[ ! "${current_index}" =~ ^[0-9]+$ ]] || [[ ! "${total_count}" =~ ^[0-9]+$ ]]; then
    echo "Usage: progressbar {current_index} {total_count}" >&2
    return 1
  fi

  local margin="7"
  local width=$((COLUMNS - margin))

  local progress=$((current_index * 100 * 100 / total_count / 100))
  local done_count=$((progress * width / 10 / 10))
  local left_count=$((width - done_count))

  local fill_chars="${(r:${done_count}::#:)}"
  local empty_chars="${(r:${left_count}:: :)}"

  printf "\r[%s%s] %3d%%" "${fill_chars}" "${empty_chars}" "${progress}"
}

# Remove escape sequences
# https://stackoverflow.com/questions/17998978/removing-colors-from-output
# https://stackoverflow.com/questions/19296667/remove-ansi-color-codes-from-a-text-file-using-bash
function remove_escape_sequences {
  local sed_args=()

  if echo | sed -r > /dev/null 2>&1; then
    sed_args+=("-r")
  else
    sed_args+=("-E")
  fi

  sed_args+=('s/[[:cntrl:]]\[([0-9]{1,3}(;[0-9]{1,3}){0,4})?[fmGHJK]//g')

  sed "${sed_args[@]}"
}
