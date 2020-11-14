function setup_my_ruby_path {
  # Depend on rbenv
  local _path="$HOME/.rbenv/shims"

  if [ -f "$_path" ]; then
    export PATH="$PATH:$_path"
  fi

  unset -f setup_my_ruby_path
}
setup_my_ruby_path
