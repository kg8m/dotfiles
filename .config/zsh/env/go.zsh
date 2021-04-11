function plugin:setup:env:go {
  # Depend on goenv; see also `.config/zsh/goenv.zsh`
  local gopath="$(find ~/go -maxdepth 1 -mindepth 1 -type d | sort --version-sort | tail -n1)"

  if [ -n "$gopath" ] && [ -d "$gopath/bin" ]; then
    path=("${path[@]}" "$gopath/bin")
  fi

  unset -f plugin:setup:env:go
}
plugin:setup:env:go
