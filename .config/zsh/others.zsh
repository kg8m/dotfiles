function plugin:others:setup {
  # eza
  export TIME_STYLE="long-iso"

  # MySQL
  mkdir -p "${XDG_DATA_HOME:?}/mysql"
  export MYSQL_HISTFILE="${XDG_DATA_HOME:?}/mysql/history"

  # ngrok
  if ((${+commands[ngrok]})); then
    eval "$(ngrok completion)"
  else
    echo:warn "\`ngrok completion\` is skipped because ngrok is not available."
  fi

  # themis.vim
  # Don't use zinit's options like `as"command" pick"bin/themis"` because it makes the `$PATH` longer and longer. Make
  # symbolic links in `${HOME}/bin` instead.
  #
  # shellcheck disable=SC2317
  function plugin:vim:themis:atclone {
    local binary="bin/themis"

    mkdir -p "${HOME}/bin"
    ln -fs "${PWD}/${binary}" "${HOME}/bin/$(basename "${binary}")"
  }
  zinit ice lucid as"null" atclone"plugin:vim:themis:atclone"
  zinit light thinca/vim-themis

  # Tig
  mkdir -p "${XDG_DATA_HOME:?}/tig"

  unset -f plugin:others:setup
}
zinit ice lucid wait"0c" atload"plugin:others:setup"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-others-setup"

# cf. async_start_worker, async_stop_worker, async_job, and so on
zinit ice lucid wait"0c"
zinit light mafredri/zsh-async
