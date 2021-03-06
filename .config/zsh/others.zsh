function plugin:setup:others {
  if [ "$(uname)" = "Darwin" ]; then
    zinit ice lucid as"null" from"gh-r" bpick"tbkeys.xpi" atclone"execute_with_echo 'open .'" atpull"%atclone"
    zinit light wshanks/tbkeys
  fi

  # Don't use zinit's options like `as"command" pick"bin/themis"` because it makes the `$PATH` longer and longer. Make
  # symbolic links in `$HOME/bin` instead.
  function plugin:setup:vim_themis {
    local binary="bin/themis"

    mkdir -p "$HOME/bin"
    ln -fs "$PWD/${binary}" "$HOME/bin/$(basename "$binary")"
  }
  zinit ice lucid wait"0c" as"null" atclone"plugin:setup:vim_themis"
  zinit light thinca/vim-themis

  mkdir -p "${XDG_DATA_HOME:?}/mysql"
  export MYSQL_HISTFILE="${XDG_DATA_HOME:?}/mysql/history"

  unset -f plugin:setup:others
}

zinit ice lucid wait"0c" atload"plugin:setup:others"
zinit snippet /dev/null
