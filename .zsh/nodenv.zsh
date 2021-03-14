function plugin:setup:nodenv {
  if [ -d ~/.nodenv ]; then
    export PATH=~/.nodenv/bin:$PATH

    if command -v nodenv > /dev/null; then
      if ! [ -f "${KG8M_ZSH_CACHE_DIR:?}/nodenv_init" ]; then
        nodenv init - > "$KG8M_ZSH_CACHE_DIR/nodenv_init"
        zcompile "$KG8M_ZSH_CACHE_DIR/nodenv_init"
      fi
      source "$KG8M_ZSH_CACHE_DIR/nodenv_init"
    fi
  fi

  unset -f plugin:setup:nodenv
}

zinit ice lucid nocd wait"0a" atload"plugin:setup:nodenv"
zinit snippet /dev/null
