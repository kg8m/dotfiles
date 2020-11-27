function plugin:setup:env:go {
  # Depend on goenv; see also `.zsh/goenv.zsh`
  local _path="$(find ~/go -maxdepth 1 -mindepth 1 -type d | sort --version-sort | tail -n1)"

  if [ -n "$_path" ]; then
    export PATH="$PATH:$_path/bin"
  fi

  unset -f plugin:setup:env:go
}
plugin:setup:env:go
