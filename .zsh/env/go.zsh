function setup_my_go_path {
  # Depend on goenv; see also `.zsh/goenv.zsh`
  local _path="$( find ~/go -type d -depth 1 | sort | tail -n1 )"

  if [ "$_path" ]; then
    export PATH="$PATH:$_path/bin"
  fi
}
setup_my_go_path
