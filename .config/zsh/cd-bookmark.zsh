function plugin:cdbookmark:atinit {
  export CD_BOOKMARK_FILE="${XDG_DATA_HOME:?}/cdbookmark/data"
  mkdir -p "$(dirname "${CD_BOOKMARK_FILE}")"

  unset -f plugin:cdbookmark:atinit
}
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \${PWD}" atpull"%atclone" atinit="plugin:cdbookmark:atinit"
zinit light mollifier/cd-bookmark
