# See also `.zsh/env/go.zsh`
function setup_my_goenv {
  export GOENV_ROOT="$( pwd )"
  export PATH=$GOENV_ROOT/bin:$PATH

  eval "$( goenv init - )"

  if [ "$GOROOT" ] && [ "$GOPATH" ]; then
    # Disable because this obstructs $GOENV_ROOT/shims
    # export PATH=$GOROOT/bin:$PATH

    export PATH=$PATH:$GOPATH/bin
  fi

  unset -f setup_my_goenv
}
zinit ice lucid wait"!0a" as"null" atload"setup_my_goenv"; zinit light syndbg/goenv
