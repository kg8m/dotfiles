function plugin:direnv:atload {
  if command -v direnv > /dev/null; then
    if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/direnv_hook.zsh" ]; then
      direnv hook zsh > "${KG8M_ZSH_CACHE_DIR}/direnv_hook.zsh"

      # cf. zsh:rcs:compile() and zsh:rcs:compile:clear()
      zcompile "${KG8M_ZSH_CACHE_DIR}/direnv_hook.zsh"
    fi
    source "${KG8M_ZSH_CACHE_DIR}/direnv_hook.zsh"

    # Don't cache the result of `direnv export zsh` because it varies depending on each directory's `.envrc`
    # https://github.com/direnv/direnv/blob/a4632773637ee1a6b08fa81043cacd24ea941489/shell_zsh.go#L12
    eval "$(direnv export zsh)"
  else
    # shellcheck disable=SC2317
    function plugin:direnv:not_installed_error {
      if [ -f .envrc ]; then
        echo:warn ".envrc exists but direnv isn't installed."
      fi
    }
    add-zsh-hook chpwd plugin:direnv:not_installed_error
  fi

  unset -f plugin:direnv:atload
}

function() {
  local ice_options=(lucid nocd atload"plugin:direnv:atload")

  # immediately load direnv and, reflect envs if `.envrc` exists.
  if [ ! -f ".envrc" ]; then
    ice_options+=(wait"0b")
  fi

  zinit ice "${ice_options[@]}"
  zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-direnv-atload"
}
