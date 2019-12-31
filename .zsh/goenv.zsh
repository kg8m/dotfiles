function setup_goenv {
  export GOENV_ROOT="$( pwd )"
  export PATH=$GOENV_ROOT/bin:$PATH

  eval "$( goenv init - )"

  export PATH=$GOROOT/bin:$PATH
  export PATH=$GOPATH/bin:$PATH
}
zplugin ice lucid wait as"null" atload"setup_goenv"; zplugin light syndbg/goenv
