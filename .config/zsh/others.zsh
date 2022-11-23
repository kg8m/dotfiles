function plugin:others:setup {
  # For exa
  # https://the.exa.website/docs/environment-variables
  export TIME_STYLE="long-iso"

  # Don't use zinit's options like `as"command" pick"bin/themis"` because it makes the `$PATH` longer and longer. Make
  # symbolic links in `${HOME}/bin` instead.
  function plugin:vim:themis:atclone {
    local binary="bin/themis"

    mkdir -p "${HOME}/bin"
    ln -fs "${PWD}/${binary}" "${HOME}/bin/$(basename "${binary}")"
  }
  zinit ice lucid as"null" atclone"plugin:vim:themis:atclone"
  zinit light thinca/vim-themis

  mkdir -p "${XDG_DATA_HOME:?}/mysql"
  export MYSQL_HISTFILE="${XDG_DATA_HOME:?}/mysql/history"

  mkdir -p "${XDG_DATA_HOME:?}/tig"

  unset -f plugin:others:setup
}
zinit ice lucid wait"0c" atload"plugin:others:setup"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-others-setup"

# cf. async_start_worker, async_stop_worker, async_job, and so on
zinit ice lucid wait"0c"
zinit light mafredri/zsh-async
