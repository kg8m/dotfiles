function plugin:setup:direnv {
  if command -v direnv > /dev/null; then
    if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/direnv_hook" ]; then
      direnv hook zsh > "${KG8M_ZSH_CACHE_DIR}/direnv_hook"
      zcompile "${KG8M_ZSH_CACHE_DIR}/direnv_hook"
    fi
    source "${KG8M_ZSH_CACHE_DIR}/direnv_hook"

    # Don't cache the result of `direnv export zsh` because it varies depending on each directory's `.envrc`
    # https://github.com/direnv/direnv/blob/a4632773637ee1a6b08fa81043cacd24ea941489/shell_zsh.go#L12
    eval "$(direnv export zsh)"
  else
    function error_for_envrc {
      if [ -f .envrc ]; then
        echo:warn ".envrc exists but direnv isn't installed."
      fi
    }
    add-zsh-hook chpwd error_for_envrc
  fi

  unset -f plugin:setup:direnv
}

function() {
  local ice_options=(lucid nocd pick"/dev/null" atload"plugin:setup:direnv")

  # immediately load direnv and, reflect envs if `.envrc` exists.
  if [ ! -f ".envrc" ]; then
    ice_options+=(wait"0b")
  fi

  zinit ice "${ice_options[@]}"
  zinit snippet /dev/null
}
