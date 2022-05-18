function plugin:others:setup {
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
zinit ice lucid wait"0c" pick"/dev/null" atload"plugin:others:setup"
zinit snippet /dev/null

# cf. async_start_worker, async_stop_worker, async_job, and so on
zinit ice lucid wait"0c"
zinit light mafredri/zsh-async
