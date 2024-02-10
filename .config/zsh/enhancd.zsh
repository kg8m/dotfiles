function plugin:enhancd:with_mkdir {
  if [ "$#" = "1" ] && [[ ! "$1" =~ ^$\|^-$ ]] && [ ! -d "$1" ]; then
    echo:info "\"$1\" doesn’t exist."
    execute_with_confirm "mkdir -p \"$1\""
  fi

  __enhancd::cd "$@"
}

function plugin:enhancd:atload {
  alias cd="plugin:enhancd:with_mkdir"
  unset -f plugin:enhancd:atload
}

export ENHANCD_DIR="${XDG_DATA_HOME:?}/enhancd"
export ENHANCD_FILTER="filter --preview-window 'hidden'"

zinit ice lucid trigger-load!"cd" atload"plugin:enhancd:atload"
zinit light b4b4r07/enhancd
PLUGINS_FOR_TRIGGER_LOAD+=("b4b4r07/enhancd")
