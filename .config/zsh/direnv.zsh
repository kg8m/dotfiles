if ((${+commands[direnv]})); then
  if [ ! -f "${XDG_CACHE_HOME:?}/zsh/direnv_hook.zsh" ]; then
    direnv hook zsh > "$(ensure_dir "${XDG_CACHE_HOME}/zsh/direnv_hook.zsh")"

    # cf. zsh:rcs:compile() and zsh:rcs:compile:clear()
    zcompile "${XDG_CACHE_HOME}/zsh/direnv_hook.zsh"
  fi
  source "${XDG_CACHE_HOME}/zsh/direnv_hook.zsh"

  # Don't cache the result of `direnv export zsh` because it varies depending on each directory's `.envrc`
  # https://github.com/direnv/direnv/blob/93cd37820c29a1f96a0e64ff1557a7a912866d4f/internal/cmd/shell_zsh.go#L12
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
