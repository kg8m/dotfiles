if [ -d ~/.rbenv ]; then
  export PATH=~/.rbenv/bin:$PATH

  if which rbenv > /dev/null 2>&1; then
    zplugin ice wait atinit'eval "$( rbenv init - )"'

    [ -d ~/.rbenv/plugins ] || mkdir -p ~/.rbenv/plugins
    [ -d ~/.rbenv/plugins/rbenv-update ] || ln -s ~/dotfiles/.rbenv/plugins/rbenv-update ~/.rbenv/plugins/rbenv-update
  fi
fi
