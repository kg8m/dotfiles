function plugin:others:setup {
  # eza
  export TIME_STYLE="long-iso"

  # MySQL
  mkdir -p "${XDG_DATA_HOME:?}/mysql"
  export MYSQL_HISTFILE="${XDG_DATA_HOME:?}/mysql/history"

  # themis.vim
  # Don’t use zinit’s options like `as"command" pick"bin/themis"` because it makes the `$PATH` longer and longer. Make
  # symbolic links in `${HOME}/bin` instead.
  #
  # shellcheck disable=SC2317
  function plugin:vim:themis:atclone {
    local binary="bin/themis"

    mkdir -p "${HOME}/bin"
    ln -fs "${PWD}/${binary}" "${HOME}/bin/$(basename "${binary}")"
  }
  # shellcheck disable=SC2317
  function plugin:vim:themis:atload {
    # For zsh:plugins:update
    export THEMIS_HOME="${PWD}"
  }
  zinit ice lucid as"null" atclone"plugin:vim:themis:atclone" atload"plugin:vim:themis:atload"
  zinit light thinca/vim-themis

  # Tig
  mkdir -p "${XDG_DATA_HOME:?}/tig"

  # zsh-async
  # cf. async_start_worker, async_stop_worker, async_job, and so on
  zinit ice lucid
  zinit light mafredri/zsh-async

  unset -f plugin:others:setup
}
zinit ice lucid wait"0c" atload"plugin:others:setup"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-others-setup"
