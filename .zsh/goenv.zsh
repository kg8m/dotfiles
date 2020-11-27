# See also `.zsh/env/go.zsh`
function plugin:setup:goenv {
  export GOENV_ROOT="$PWD"
  export PATH=$GOENV_ROOT/bin:$PATH

  if ! [ -f "${KGYM_ZSH_CACHE_DIR:-}/goenv_init" ]; then
    goenv init - > "$KGYM_ZSH_CACHE_DIR/goenv_init"
    zcompile "$KGYM_ZSH_CACHE_DIR/goenv_init"
  fi
  source "$KGYM_ZSH_CACHE_DIR/goenv_init"

  if [ -n "${GOROOT:-}" ] && [ -n "${GOPATH:-}" ]; then
    # Disable because this obstructs $GOENV_ROOT/shims
    # export PATH=$GOROOT/bin:$PATH

    export PATH=$PATH:$GOPATH/bin
  fi

  unset -f plugin:setup:goenv
}
zinit ice lucid wait"0a" as"null" atload"plugin:setup:goenv"
zinit light syndbg/goenv
