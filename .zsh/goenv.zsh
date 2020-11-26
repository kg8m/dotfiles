# See also `.zsh/env/go.zsh`
function setup_my_goenv {
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

  unset -f setup_my_goenv
}
zinit ice lucid wait"0a" as"null" atload"setup_my_goenv"
zinit light syndbg/goenv
