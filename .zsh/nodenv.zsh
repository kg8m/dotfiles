function setup_my_nodenv {
  if [ -d ~/.nodenv ]; then
    export PATH=~/.nodenv/bin:$PATH

    if command -v nodenv > /dev/null 2>&1; then
      if ! [ -f "$KGYM_ZSH_CACHE_DIR/nodenv_init" ]; then
        nodenv init - > "$KGYM_ZSH_CACHE_DIR/nodenv_init"
        zcompile "$KGYM_ZSH_CACHE_DIR/nodenv_init"
      fi
      source "$KGYM_ZSH_CACHE_DIR/nodenv_init"
    fi
  fi

  unset -f setup_my_nodenv
}

zinit ice lucid nocd wait"0a" atload"setup_my_nodenv"; zinit snippet /dev/null
