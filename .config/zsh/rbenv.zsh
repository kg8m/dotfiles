function plugin:setup:rbenv {
  if [ -d ~/.rbenv ] && command -v rbenv > /dev/null; then
    if ! [ -f "${KG8M_ZSH_CACHE_DIR:?}/rbenv_init" ]; then
      rbenv init - > "$KG8M_ZSH_CACHE_DIR/rbenv_init"
      zcompile "$KG8M_ZSH_CACHE_DIR/rbenv_init"
    fi
    source "$KG8M_ZSH_CACHE_DIR/rbenv_init"

    mkdir -p ~/.rbenv/plugins

    function plugin:setup:rbenv_default_gems {
      remove_symlink ~/dotfiles/.rbenv/default-gems
      remove_symlink ~/.rbenv/plugins/rbenv-default-gems

      if ! [ -f ~/.rbenv/default-gems ]; then
        ln -s ~/dotfiles/.rbenv/default-gems ~/.rbenv/default-gems
      fi

      if ! [ -d ~/.rbenv/plugins/rbenv-default-gems ]; then
        ln -s "$PWD" ~/.rbenv/plugins/rbenv-default-gems
      fi

      unset -f plugin:setup:rbenv_default_gems
    }

    function plugin:setup:rbenv_each {
      remove_symlink ~/.rbenv/plugins/rbenv-each

      if ! [ -d ~/.rbenv/plugins/rbenv-each ]; then
        ln -s "$PWD" ~/.rbenv/plugins/rbenv-each
      fi

      unset -f plugin:setup:rbenv_each
    }

    function plugin:setup:ruby_build {
      remove_symlink ~/.rbenv/plugins/ruby-build

      if ! [ -d ~/.rbenv/plugins/ruby-build ]; then
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
