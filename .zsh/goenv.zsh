if [ -d ~/.goenv ]; then
  export GOENV_ROOT=$HOME/.goenv
  export PATH=$GOENV_ROOT/bin:$PATH

  zplugin ice wait atinit'eval "$( goenv init - )"'

  export PATH=$GOROOT/bin:$PATH
  export PATH=$GOPATH/bin:$PATH
fi
