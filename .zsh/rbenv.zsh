function plugin:setup:rbenv {
  if [ -d ~/.rbenv ] && command -v rbenv > /dev/null; then
    if ! [ -f "${KGYM_ZSH_CACHE_DIR:-}/rbenv_init" ]; then
      rbenv init - > "$KGYM_ZSH_CACHE_DIR/rbenv_init"
      zcompile "$KGYM_ZSH_CACHE_DIR/rbenv_init"
    fi
    source "$KGYM_ZSH_CACHE_DIR/rbenv_init"

    function plugin:setup:rbenv_default_gems {
      if [ ! -f ~/.rbenv/default-gems ]; then
        mkdir -p ~/.rbenv
        ln -s ~/dotfiles/.rbenv/default-gems ~/.rbenv/default-gems
      fi

      if [ ! -d ~/.rbenv/plugins/rbenv-default-gems ]; then
        mkdir -p ~/.rbenv/plugins
        ln -s "$PWD" ~/.rbenv/plugins/rbenv-default-gems
      fi

      unset -f plugin:setup:rbenv_default_gems
    }

    function plugin:setup:rbenv_each {
      if [ ! -d ~/.rbenv/plugins/rbenv-each ]; then
        mkdir -p ~/.rbenv/plugins
        ln -s "$PWD" ~/.rbenv/plugins/rbenv-each
      fi

      unset -f plugin:setup:rbenv_each
    }

    function plugin:setup:ruby_build {
      if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
        mkdir -p ~/.rbenv/plugins
        ln -s "$PWD" ~/.rbenv/plugins/ruby-build
      fi

      unset -f plugin:setup:ruby_build
    }

    zinit ice lucid as"null" atclone"plugin:setup:rbenv_default_gems"
    zinit light rbenv/rbenv-default-gems

    zinit ice lucid as"null" atclone"plugin:setup:rbenv_each"
    zinit light rbenv/rbenv-each

    zinit ice lucid as"null" atclone"plugin:setup:ruby_build"
    zinit light rbenv/ruby-build
  fi

  unset -f plugin:setup:rbenv
}

zinit ice lucid nocd wait"0a" atload"plugin:setup:rbenv"
zinit snippet /dev/null
