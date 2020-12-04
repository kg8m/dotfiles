function plugin:setup:others {
  if [ "$(uname)" = "Darwin" ]; then
    function plugin:setup:tbkeys {
      execute_with_echo "cp tbkeys.xpi $HOME/Downloads"
    }
    zinit ice lucid as"null" from"gh-r" bpick"tbkeys.xpi" atclone"plugin:setup:tbkeys" atpull"%atclone"
    zinit light wshanks/tbkeys
  fi

  unset -f plugin:setup:others
}

zinit ice lucid wait"0c" atload"plugin:setup:others"
zinit snippet /dev/null
