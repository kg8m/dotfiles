function setup_my_go_path {
  # Depend on goenv; see also `.zsh/goenv.zsh`
  local _path="$( find ~/go -maxdepth 1 -mindepth 1 -type d | sort --version-sort | tail -n1 )"

  if [ "$_path" ]; then
    export PATH="$PATH:$_path/bin"
  fi

  unset -f setup_my_go_path
}
setup_my_go_path
