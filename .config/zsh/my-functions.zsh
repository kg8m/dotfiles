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
    echo:info "Remove a symlink ${filepath}."
    rm "${filepath}"
  else
    echo:warn "${filepath} is not a symbolic link."
  fi
}

function tmux:setup_default {
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

function tmux:attach_or_new {
  local session_name="${1:-default}"

  if ! tmux has-session -t "${session_name}" > /dev/null 2>&1; then
    local response
    read -r "response?Create new session in directory \`${PWD}\` with session name \`${session_name}\`? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      if [ "${session_name}" = "default" ]; then
        tmux:setup_default
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

# cf. Vim's kg8m#util#grep#BuildQflistFromBuffer()
function my_grep:with_filter {
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

  local filter_header=(
    "${query}"
  )

  # cf. `my_grep`
  if [ -n "${RIPGREP_EXTRA_OPTIONS:-}" ]; then
    filter_header+=("${=RIPGREP_EXTRA_OPTIONS}")
  fi

  filter_header+=("${options[*]}" "${non_options[*]}")

  local grep_args=(
    "${query}"
    --column
    --line-number
    --no-heading
    --color always
    --with-filename
  )
  local filter_args=(
    --header "Grep: ${filter_header[*]}"
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
        execute_with_echo "vim -c 'call kg8m#util#grep#BuildQflistFromBuffer()' '${tempfile}'"

        rm -f "${tempfile}"
      else
        # shellcheck disable=SC2145
        execute_with_echo "vim '${(j:' ':)results[@]}'"
      fi
    fi
  fi
}

function docker:containers:delete {
  local container_names=("${(@f)$(
    docker container ls --all |
      filter --header-lines 1 |
      awk '{ print $NF }'
  )}")

  if [ -n "${container_names[*]}" ]; then
    local container_name
    for container_name in "${container_names[@]}"; do
      execute_with_confirm "docker container rm ${container_name}"
    done
  else
    echo:info "There are no containers."
  fi

  execute_with_echo "docker container ls --all"
}

function docker:images:delete {
  local image_names=("${(@f)$(
    docker images --all |
      filter --header-lines 1 |

      # Use image ID if the repository name is `<none>`. Otherwise, use image repository with tag.
      #   $1: image repository, e.g., postgres
      #   $2: image tag, e.g., 14.2
      #   $3: image ID (random characters)
      awk '{ if ($1 == "<none>") { print $3 } else { print $1":"$2 } }'
  )}")

  if [ -n "${image_names[*]}" ]; then
    local image_name
    for image_name in "${image_names[@]}"; do
      execute_with_confirm "docker rmi ${image_name}"
    done
  else
    echo:info "There are no images."
  fi

  execute_with_echo "docker images --all"
}

function docker:volumes:delete {
  local volume_names=("${(@f)$(
    docker volume ls |
      filter --header-lines 1 |
      awk '{ print $2 }'
  )}")

  if [ -n "${volume_names[*]}" ]; then
    local volume_name
    for volume_name in "${volume_names[@]}"; do
      execute_with_confirm "docker volume rm ${volume_name}"
    done
  else
    echo:info "There are no volumes."
  fi

  execute_with_echo "docker volume ls"
}

function docker:clear_all {
  local commands=(
    "docker:containers:delete"
    "docker:images:delete"
    "docker:volumes:delete"
    "docker builder prune"
  )

  execute_commands_with_echo "${commands[@]}" --separate
}

function zsh:plugins:update {
  execute_with_echo "trash '${KG8M_ZSH_CACHE_DIR:?}'"
  execute_with_echo "mkdir -p '${KG8M_ZSH_CACHE_DIR}'"

  execute_with_echo "zsh:rcs:compile:clear"

  execute_with_echo "zinit delete --clean --yes"
  execute_with_echo "zinit cclear"
  execute_with_echo "find ${ZINIT[SNIPPETS_DIR]:?} -type d -empty -delete"

  # Use subshell to restore pwd.
  (
    # Clean up the directory because enhancd makes it dirty when loaded.
    execute_with_echo "cd ${ENHANCD_ROOT:?}"
    execute_with_echo "git restore ."
  )

  execute_with_echo "zinit update --all --parallel --quiet"

  # Use subshell to restore pwd.
  (
    # Remove `_*.fish` files because they are treated as completions by zinit.
    execute_with_echo "cd ${ENHANCD_ROOT:?}"
    execute_with_echo "rm -f ./**/_*.fish"
  )

  execute_with_echo "zinit creinstall ${ZINIT[BIN_DIR]}"
  execute_with_echo "zinit csearch"

  execute_with_echo "zsh:rcs:compile"

  execute_with_echo "exec zsh"
}

function zsh:rcs:compile {
  local zshrc
  for zshrc in ~/.config/zsh/*.zsh ~/.config/zsh.local/.z* ~/.zshenv* ~/.zshrc*; do
    if [ -f "${zshrc}" ] && [[ ! "${zshrc}" =~ \.zwc$ ]]; then
      zcompile "${zshrc}"
    fi
  done
}

function zsh:rcs:compile:clear {
  local zwc
  for zwc in ~/.config/zsh/*.zsh.zwc ~/.config/zsh.local/.z*.zwc ~/.zshenv*.zwc ~/.zshrc*.zwc; do
    if [ -f "${zwc}" ]; then
      rm -f "${zwc}"
    fi
  done
}

function libs:go:uninstall {
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

function benchmark:vim {
  local vim=${1:-vim}

  execute_with_echo "${vim} --version | awk '/^VIM - Vi IMproved/,/Features included \\(\\+\\) or not \\(-\\):$/'"
  execute_with_echo "${vim} -c 'call kg8m#plugin#RecacheRuntimepath() | q'"

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

function benchmark:zsh {
  execute_with_echo "zsh:rcs:compile:clear"
  execute_with_echo "zsh:rcs:compile"
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
