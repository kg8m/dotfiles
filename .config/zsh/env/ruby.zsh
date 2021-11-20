function() {
  # Depend on rbenv
  local shims="${HOME}/.rbenv/shims"

  if [ -d "${shims}" ]; then
    path=("${shims}" "${path[@]}")
  fi
}
