function setup_my_ruby_path {
  # Depend on rbenv
  local _path="$HOME/.rbenv/shims"

  if [ "$_path" ]; then
    export PATH="$PATH:$_path"
  fi
}
setup_my_ruby_path