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

  # shellcheck disable=SC2198
  if [ ! "${@[(I)--ignore-failure]}" = "0" ]; then
    local ignore_failure="1"
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

    if [ ! "${ignore_failure}" = "1" ] && [ ! "${result}" = "0" ]; then
      return 1
    fi
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
  echo -e "\e[38;5;239m${(r:${COLUMNS}::-:)}\e[0m"
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

function highlight:blue {
  highlight:base "4" "$@"
}

function highlight:magenta {
  highlight:base "5" "$@"
}

function highlight:cyan {
  highlight:base "6" "$@"
}

function highlight:pink {
  highlight:base "219" "$@"
}

function highlight:gray {
  highlight:base "245" "$@"
}

# cf. Vim's `kg8m#util#string#colors#Red()` and so on
function highlight:base {
  local color="${1:?}"
  shift 1

  local style="1"  # bold
  local fgbg="38"  # fg
  local args=()

  local arg
  for arg in "$@"; do
    case "${arg}" in
      --no-bold)
        style="0"  # non-bold
        ;;
      --bg)
        fgbg="48"  # bg
        ;;
      *)
        args+=("${arg}")
        ;;
    esac

    shift 1
  done

  printf "\e[%d;%d;5;%dm%s\e[0;0m" "${style}" "${fgbg}" "${color}" "${args[*]}"
}

function echo:error {
  printf "%s\n" "$(highlight:red "ERROR -- $*")" >&2
}

function echo:warn {
  printf "%s\n" "$(highlight:yellow "WARN -- $*")" >&2
}

function echo:info {
  printf "%s\n" "$(highlight:cyan "INFO -- $*" --no-bold)" >&2
}

# cf. `man zshcontrib` for `zmv`
function batch_move {
  local dryrun_result=("${(@f)$(zmv -n "$@")}")

  if [ -z "${dryrun_result[*]}" ]; then
    return 1
  fi

  echo "${(j:\n:)dryrun_result}" | less

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
      # Rename to preventing duplication.
      #   - foo         => foo 12.34.56.7890
      #   - foo.bar     => foo 12.34.56.7890.bar
      #   - foo.bar.baz => foo 12.34.56.7890.bar.baz
      new_filename="$(echo "${filename}" | tr -d "\n" | sd '^(\.?[^.]+)(\.?)' "\$1 ${timestamp}.${RANDOM}\$2")"
    else
      new_filename="${filename}"
    fi

    touch "${source}"
    execute_with_echo "mv '${source}' '${trash_path}/${new_filename}'"
  done
}

function trash:bulk {
  local dirpath="${1:-.}"

  if [ ! -d "${dirpath}" ]; then
    echo:error "${dirpath} doesn’t exist."
    return 1
  fi

  local filepaths=("${(@f)$(
    fd --type f . "${dirpath}" |
      filter \
        --prompt "Select files> " \
        --preview "preview {}" \
        --preview-window "down:75%:wrap:nohidden"
  )}")

  if [ -n "${filepaths[*]}" ]; then
    execute_with_confirm "trash '${(j:' ':)filepaths}'"
  else
    echo:info "Canceled."
  fi
}

function remove_empty_dirs {
  local search_path="${1:-.}"

  if (("${#@}" > 0)); then
    shift 1
  fi

  echo "Finding empty directories..."
  echo
  local dirpaths=("${(@f)$(fd --full-path --type d --type e "${search_path}")}")

  if [ -n "${dirpaths[*]}" ]; then
    echo "${(j:\n:)dirpaths}"
    echo

    local response
    read -r "response?Delete them? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      rm -fr "${dirpaths[@]}"
      echo
      remove_empty_dirs "${search_path}"
    else
      echo:info "Canceled."
    fi
  else
    echo:info "There are no empty directories."
  fi
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

function delta:select:one {
  local dirpath="${1:-.}"

  if [ ! -d "${dirpath}" ]; then
    echo:error "${dirpath} doesn’t exist."
    return 1
  fi

  local filepath="$(
    fd --type f . "${dirpath}" |
      filter \
        --prompt "Select a file> " \
        --no-multi --query ".diff$" \
        --preview "preview {}" \
        --preview-window "down:75%:wrap:nohidden"
  )"

  if [ -z "${filepath}" ]; then
    echo:info "Canceled."
    return
  elif [ ! -f "${filepath}" ]; then
    echo:error "${filepath} doesn’t exist."
    return 1
  fi

  preview "${filepath}"
}

function delta:select:two {
  local dirpath="${1:-.}"

  if [ ! -d "${dirpath}" ]; then
    echo:error "${dirpath} doesn’t exist."
    return 1
  fi

  local filepaths=("${(@f)$(
    fd --type f . "${dirpath}" |
      filter \
        --prompt "Select 2 files> " \
        --multi \
        --preview "preview {}" \
        --preview-window "down:75%:wrap:nohidden"
  )}")

  if [ -z "${filepaths[*]}" ]; then
    echo:info "Canceled."
    return
  elif (("${#filepaths}" != 2)); then
    echo:error "Select just 2 files. Selected files: ${(j:, :)filepaths}"
    return 1
  elif [ ! -f "${filepaths[1]}" ]; then
    echo:error "${filepaths[1]} doesn’t exist."
    return 1
  elif [ ! -f "${filepaths[2]}" ]; then
    echo:error "${filepaths[2]} doesn’t exist."
    return 1
  fi

  delta "${filepaths[@]}"
}

# Overwrite this function if needed.
function tmux:setup_default {
  tmux new-session -d -s default
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

  while (("${#@}" > 0)); do
    case "$1" in
      --*)
        options+=("$1")

        if ! [[ "$1" =~ = ]]; then
          if (("${#@}" > 1)); then
            options+=("$2")
            shift 2
            continue
          fi
        fi
        ;;
      -*)
        options+=("$1")

        if [[ "$1" =~ ^-.$ ]] && [[ ! "$2" =~ ^- ]]; then
          if (("${#@}" > 1)); then
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

  echo "Searching..." >&2
  local results=("${(@f)$(my_grep "${grep_args[@]}" | filter "${filter_args[@]}")}")

  if [ -z "${results[*]}" ]; then
    return
  fi

  if [ "${options[(I)--files]}" = "0" ]; then
    echo "${(j:\n:)results}" | my_grep "${query}" "${options[@]}" 2> /dev/null
  else
    echo "${(j:\n:)results}" 2> /dev/null
  fi

  # Check whether the output is on a terminal
  if [ -t 1 ]; then
    local response

    echo >&2
    read -r "response?Open found files? [y/n]: "

    if [[ "${response}" =~ ^y ]]; then
      if [ "${options[(I)--files]}" = "0" ]; then
        local tempfile="$(mktemp "${TMPDIR%/}/grep.XXXXXXXXXX")"

        # Don't execute `echo ... | vim ... -` because current command remains as zsh if so. So tmux's
        # `pane_current_command` always returns "zsh" and automatic refreshing zsh prompt will be influenced.
        echo "${(j:\n:)results}" | grep -E '^.+?:[0-9]+:[0-9]+:.' > "${tempfile}"
        local query_for_vim="$(echo "${query}" | sd '"' '\\"' | sd "'" "'\\\\'\\\\''")"
        execute_with_echo "vim -c 'call kg8m#util#grep#BuildQflistFromBuffer('\\''${query_for_vim}'\\'')' '${tempfile}'"

        rm -f "${tempfile}"
      else
        # shellcheck disable=SC2145
        execute_with_echo "vim '${(j:' ':)results}'"
      fi
    fi
  fi
}

function my_diff {
  local options=(
    --unified=10
    --recursive
    --new-file
    --exclude=".git"
  )

  execute_with_echo "diff ${options[*]} $* | delta"
}

function my_diff:without_spaces {
  local options=(
    --ignore-space-change
    --ignore-all-space
    --ignore-blank-lines
  )

  my_diff "${options[@]}" "$@"
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

function rails:routes:with_filter {
  # cf. .config/zsh/bin/rails-routes
  rails-routes | filter --header-lines 1 --preview-window "hidden" "$@"
}

function rails:routes:cache:reset {
  local filepath
  for filepath in tmp/cache/routes_*; do
    if [ -f "${filepath}" ]; then
      trash "${filepath}"
    fi
  done
}

function rails:assets:precompile:force {
  if [ ! -d "app" ] || [ ! -f "config/environment.rb" ] && [ ! -f "bin/rails" ]; then
    echo:error "Maybe non-Rails directory."
    return 1
  fi

  local prefix=""

  while (("${#@}" > 0)); do
    case "$1" in
      --environment | -e)
        prefix="RAILS_ENV=${2:-} "
        shift 2
        ;;
      *)
        echo:error "Unknown argument: $1"
        return 1
        ;;
    esac
  done

  rails:assets:clean:force
  execute_with_echo "${prefix}rails assets:precompile"
}

function rails:assets:clean:force {
  if [ ! -d "app" ] || [ ! -f "config/environment.rb" ] && [ ! -f "bin/rails" ]; then
    echo:error "Maybe non-Rails directory."
    return 1
  fi

  # cf. $EZA_IGNORE_GLOB in .zshenv
  # cf. .config/ctags/default.ctags
  # cf. .config/fd/ignore
  # cf. .config/ripgrep/config
  local directories=(
    "app/assets/builds"
    "app/frontend/builds"
    "public/assets"
    "public/packs"
    "public/packs-test"
    "public/vite"
    "public/vite-dev"
    "public/vite-test"
    "tmp/cache/assets"
    "tmp/cache/webpacker"
  )

  execute_with_confirm "rm -fr ${directories[*]}"
}

function zsh:plugins:update {
  if [ -d "${XDG_CACHE_HOME:?}/zsh" ]; then
    execute_with_echo "trash '${XDG_CACHE_HOME}/zsh'"
  fi
  execute_with_echo "mkdir -p '${XDG_CACHE_HOME}/zsh'"

  execute_with_echo "zsh:rcs:compile:clear"

  # Load plugins with `trigger-load` option, because they may not be loaded and may be deleted by `zinit delete --clean`.
  local plugin_for_trigger_load
  for plugin_for_trigger_load in "${PLUGINS_FOR_TRIGGER_LOAD[@]:?}"; do
    execute_with_echo "zinit load ${plugin_for_trigger_load}"
  done

  execute_with_echo "zinit delete --clean --yes"
  execute_with_echo "zinit cclear"
  execute_with_echo "find ${ZINIT[SNIPPETS_DIR]:?} -type d -empty -delete"

  # Use subshell to restore pwd.
  (
    # Clean up the directory because enhancd makes it dirty when loaded.
    execute_with_echo "builtin cd ${ENHANCD_ROOT:?}"
    execute_with_echo "git restore ."
  )

  execute_with_echo "zinit update --all --parallel --quiet"

  # Use subshell to restore pwd.
  (
    # Remove `_*.fish` files because they are treated as completions by zinit.
    execute_with_echo "builtin cd ${ENHANCD_ROOT:?}"
    execute_with_echo "rm -f ./**/_*.fish"
  )

  execute_with_echo "zinit creinstall ${ZINIT[BIN_DIR]}"
  execute_with_echo "zinit csearch"

  execute_with_echo "zsh:rcs:compile"

  execute_with_echo "exec zsh"
}

function zsh:rcs:compile {
  zcompile ~/.zshenv
  zcompile ~/.zshrc

  local zsh_dirs=(
    "$(ensure_dir "${XDG_CONFIG_HOME:?}/zsh")"
    "$(ensure_dir "${XDG_CONFIG_HOME:?}/zsh.local")"
    "$(ensure_dir "${XDG_CACHE_HOME:?}/zsh")"
  )

  local zshrc
  command fd --no-ignore --type f --follow '\.zsh$' "${zsh_dirs[@]}" | while read -r zshrc; do
    zcompile "${zshrc}"
  done
}

function zsh:rcs:compile:clear {
  rm -f ~/.zshenv.zwc
  rm -f ~/.zshrc.zwc

  local zsh_dirs=(
    "$(ensure_dir "${XDG_CONFIG_HOME:?}/zsh")"
    "$(ensure_dir "${XDG_CONFIG_HOME:?}/zsh.local")"
    "$(ensure_dir "${XDG_CACHE_HOME:?}/zsh")"
  )

  local zwc
  command fd --no-ignore --type f '\.zsh\.zwc$' "${zsh_dirs[@]}" | while read -r zwc; do
    rm -f "${zwc}"
  done
}

function libs:go:uninstall {
  local pkg="${1:?}"

  local fd_args=("${FD_DEFAULT_OPTIONS:?[@]}")

  if [ -n "${FD_EXTRA_OPTIONS:-}" ]; then
    # $FD_EXTRA_OPTIONS is a string because direnv doesn't support arrays.
    fd_args+=("${(s: :)FD_EXTRA_OPTIONS}")
  fi

  fd_args+=(
    --type d --type x
    --color always
    "${pkg}"
    "${ASDF_DATA_DIR?:}/shims" "${ASDF_DATA_DIR?:}/installs/golang"
  )

  local pkg_paths=("${(@f)$(fd "${fd_args[@]}" | sort_without_escape_sequences)}")

  if [ -z "${pkg_paths[*]}" ]; then
    echo:error "No pkg files/directories found for ${pkg}."
    return 1
  fi

  # shellcheck disable=SC2145
  echo -e "${(j:\n:)pkg_paths}\n"

  local response
  read -r "response?Remove found files/directories? [y/n]: "

  if [[ "${response}" =~ ^y ]]; then
    echo "${(j:\n:)pkg_paths}" | while read -r libpath; do
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

function is_m1_mac {
  local uname="$(uname -a)"

  if [[ "${uname}" =~ ^Darwin ]] && [[ "${uname}" =~ arm64$ ]]; then
    echo 1
  else
    echo 0
  fi
}

# https://gist.github.com/tobym/648188
function pwdx {
  local pids=("$@")

  if [ -z "${pids[*]}" ]; then
    info:error "Specify PIDs."
    return 1
  fi

  local lsof_args=(-a -d cwd -n)
  local pid
  for pid in "${pids[@]}"; do
    lsof_args+=(-p "${pid}")
  done

  lsof "${lsof_args[@]}"
}
