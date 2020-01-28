if [ -d ~/.rbenv ] && which rbenv > /dev/null 2>&1; then
  setup_my_rbenv() {
    eval "$( rbenv init - )"
  }

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

  zinit ice lucid wait at_load"setup_my_rbenv"; zinit snippet ~/.zsh/dummy.zsh

  zinit ice lucid wait as"null" atload"setup_rbenv_default_gems"
  zinit light rbenv/rbenv-default-gems

  zinit ice lucid wait as"null" atload"setup_rbenv_each"
  zinit light rbenv/rbenv-each

  zinit ice lucid wait as"null" atload"setup_ruby_build"
  zinit light rbenv/ruby-build
fi
