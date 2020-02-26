function cd_with_mkdir() {
  if [[ ! "$@" =~ "^$|^-$" ]] && [ ! -d "$@" ]; then
    echo "$@ not exists"
    execute_with_confirm "mkdir -p \"$@\""
  fi

  __enhancd::cd "$@"
}

function setup_my_enhancd {
  export ENHANCD_FILTER=filter
  export __ENHANCD_DIR__=$( pwd )
  alias cd="cd_with_mkdir"
  unset -f setup_my_enhancd
}
zinit ice lucid wait"!0c" atload"setup_my_enhancd"; zinit light b4b4r07/enhancd
