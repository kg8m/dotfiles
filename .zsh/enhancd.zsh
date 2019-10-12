function overwrite_cd {
  function cd_with_mkdir() {
    if [[ ! "$@" =~ "^$|^-$" ]] && [ ! -d "$@" ]; then
      echo "$@ not exists"
      execute_with_confirm "mkdir -p \"$@\""
    fi

    __enhancd::cd "$@"
  }
  alias cd="cd_with_mkdir"
}

export ENHANCD_FILTER=filter
zplugin ice silent wait atload"overwrite_cd"; zplugin light b4b4r07/enhancd
