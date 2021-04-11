function plugin:setup:env:ruby {
  # Depend on rbenv
  local shims="$HOME/.rbenv/shims"

  if [ -d "$shims" ]; then
    path=("$shims" "${path[@]}")
  fi

  unset -f plugin:setup:env:ruby
}
plugin:setup:env:ruby
