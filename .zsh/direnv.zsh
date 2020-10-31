if which direnv > /dev/null 2>&1; then
  function setup_my_direnv {
    if ! [ -f "$KGYM_ZSH_CACHE_DIR/direnv_hook" ]; then
      direnv hook zsh > "$KGYM_ZSH_CACHE_DIR/direnv_hook"
      zcompile "$KGYM_ZSH_CACHE_DIR/direnv_hook"
    fi
    source "$KGYM_ZSH_CACHE_DIR/direnv_hook"

    if ! [ -f "$KGYM_ZSH_CACHE_DIR/direnv_export" ]; then
      # https://github.com/direnv/direnv/blob/a4632773637ee1a6b08fa81043cacd24ea941489/shell_zsh.go#L12
      direnv export zsh > "$KGYM_ZSH_CACHE_DIR/direnv_export"
      zcompile "$KGYM_ZSH_CACHE_DIR/direnv_export"
    fi
    source "$KGYM_ZSH_CACHE_DIR/direnv_export"

    unset -f setup_my_direnv
  }
  zinit ice lucid nocd wait"!0b" atload"setup_my_direnv"; zinit snippet /dev/null
else
  function error_for_envrc {
    if [[ -f .envrc ]]; then
      echo "WARNING: .envrc exists but direnv isn't installed." >&2
    fi
  }
  add-zsh-hook chpwd error_for_envrc
fi
