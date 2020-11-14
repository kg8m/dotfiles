function setup_my_rbenv {
  if [ -d ~/.rbenv ] && command -v rbenv > /dev/null 2>&1; then
    if ! [ -f "$KGYM_ZSH_CACHE_DIR/rbenv_init" ]; then
      rbenv init - > "$KGYM_ZSH_CACHE_DIR/rbenv_init"
      zcompile "$KGYM_ZSH_CACHE_DIR/rbenv_init"
    fi
    source "$KGYM_ZSH_CACHE_DIR/rbenv_init"

    [ -d ~/.rbenv/plugins ] || mkdir -p ~/.rbenv/plugins

    function setup_my_rbenv_default_gems {
      if [ ! -d ~/.rbenv/plugins/rbenv-default-gems ]; then
        ln -s "$(pwd)" ~/.rbenv/plugins/rbenv-default-gems
      fi

      if [ ! -f ~/.rbenv/default-gems ]; then
        ln -s ~/dotfiles/.rbenv/default-gems ~/.rbenv/default-gems
      fi

      unset -f setup_my_rbenv_default_gems
    }

    function setup_my_rbenv_each {
      if [ ! -d ~/.rbenv/plugins/rbenv-each ]; then
        ln -s "$(pwd)" ~/.rbenv/plugins/rbenv-each
      fi

      unset -f setup_my_rbenv_each
    }

    function setup_my_ruby_build {
      if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
        ln -s "$(pwd)" ~/.rbenv/plugins/ruby-build
      fi

      unset -f setup_my_ruby_build
    }

    zinit ice lucid wait"0c" as"null" atload"setup_my_rbenv_default_gems"
    zinit light rbenv/rbenv-default-gems

    zinit ice lucid wait"0c" as"null" atload"setup_my_rbenv_each"
    zinit light rbenv/rbenv-each

    zinit ice lucid wait"0c" as"null" atload"setup_my_ruby_build"
    zinit light rbenv/ruby-build
  fi

  unset -f setup_my_rbenv
}

zinit ice lucid nocd wait"0a" atload"setup_my_rbenv"
zinit snippet /dev/null
