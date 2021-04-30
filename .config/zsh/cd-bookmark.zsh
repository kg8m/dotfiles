export CD_BOOKMARK_FILE="${XDG_DATA_HOME:?}/cdbookmark/data"
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \$PWD" atpull"%atclone"
zinit light mollifier/cd-bookmark
