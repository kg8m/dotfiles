function plugin:setup:env:ruby {
  # Depend on rbenv
  local _path="$HOME/.rbenv/shims"

  if [ -f "$_path" ]; then
    export PATH="$PATH:$_path"
  fi

  unset -f plugin:setup:env:ruby
}
plugin:setup:env:ruby
