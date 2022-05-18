function plugin:enhancd:with_mkdir() {
  if [[ ! "$*" =~ ^$\|^-$ ]] && [ ! -d "$*" ]; then
    echo "$* not exists"
    execute_with_confirm "mkdir -p \"$*\""
  fi

  __enhancd::cd "$@"
}

function plugin:enhancd:atload {
  alias cd="plugin:enhancd:with_mkdir"
  unset -f plugin:enhancd:atload
}

export ENHANCD_DIR="${XDG_DATA_HOME:?}/enhancd"
export ENHANCD_FILTER=filter

zinit ice lucid wait"0c" atload"plugin:enhancd:atload"
zinit light b4b4r07/enhancd
