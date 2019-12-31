if [ -d ~/.rbenv ] && which rbenv > /dev/null 2>&1; then
  eval "$( rbenv init - )"

  [ -d ~/.rbenv/plugins ] || mkdir -p ~/.rbenv/plugins

  function setup_rbenv_default_gems {
    if [ ! -d ~/.rbenv/plugins/rbenv-default-gems ]; then
      ln -s "$( pwd )" ~/.rbenv/plugins/rbenv-default-gems
    fi

    if [ ! -f ~/.rbenv/default-gems ]; then
      ln -s ~/dotfiles/.rbenv/default-gems ~/.rbenv/default-gems
    fi
  }

  function setup_rbenv_each {
    if [ ! -d ~/.rbenv/plugins/rbenv-each ]; then
      ln -s "$( pwd )" ~/.rbenv/plugins/rbenv-each
    fi
  }

  function setup_ruby_build {
    if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
      ln -s "$( pwd )" ~/.rbenv/plugins/ruby-build
    fi
  }

  zplugin ice lucid wait as"null" atload"setup_rbenv_default_gems"
  zplugin light rbenv/rbenv-default-gems

  zplugin ice lucid wait as"null" atload"setup_rbenv_each"
  zplugin light rbenv/rbenv-each

  zplugin ice lucid wait as"null" atload"setup_ruby_build"
  zplugin light rbenv/ruby-build
fi
