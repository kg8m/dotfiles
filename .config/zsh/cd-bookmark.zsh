function plugin:setup:cdbookmark {
  export CD_BOOKMARK_FILE="${XDG_DATA_HOME:?}/cdbookmark/data"
  mkdir -p "$(dirname "${CD_BOOKMARK_FILE}")"

  unset -f plugin:setup:cdbookmark
}
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \$PWD" atpull"%atclone" atinit="plugin:setup:cdbookmark"
zinit light mollifier/cd-bookmark
