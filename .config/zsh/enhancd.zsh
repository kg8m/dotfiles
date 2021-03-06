function cd_with_mkdir() {
  if [[ ! "$*" =~ ^$\|^-$ ]] && [ ! -d "$*" ]; then
    echo "$* not exists"
    execute_with_confirm "mkdir -p \"$*\""
  fi

  __enhancd::cd "$@"
}

function plugin:setup:enhancd {
  alias cd="cd_with_mkdir"
  unset -f plugin:setup:enhancd
}

export ENHANCD_DIR="${XDG_DATA_HOME:?}/enhancd"
export ENHANCD_FILTER=filter

zinit ice lucid wait"0c" atload"plugin:setup:enhancd"
zinit light b4b4r07/enhancd
