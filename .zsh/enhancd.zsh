function cd_with_mkdir() {
  if [[ ! "$@" =~ "^$|^-$" ]] && [ ! -d "$@" ]; then
    echo "$@ not exists"
    execute_with_confirm "mkdir -p \"$@\""
  fi

  __enhancd::cd "$@"
}

export ENHANCD_FILTER=filter
zplugin ice lucid wait atload'alias cd="cd_with_mkdir"'; zplugin light b4b4r07/enhancd
