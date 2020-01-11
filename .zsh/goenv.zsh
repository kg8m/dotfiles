function setup_goenv {
  export GOENV_ROOT="$( pwd )"
  export PATH=$GOENV_ROOT/bin:$PATH

  eval "$( goenv init - )"

  if [ "$GOROOT" ] && [ "$GOPATH" ]; then
    export PATH=$GOROOT/bin:$PATH
    export PATH=$GOPATH/bin:$PATH
  fi
}
zplugin ice lucid wait as"null" atload"setup_goenv"; zplugin light syndbg/goenv
