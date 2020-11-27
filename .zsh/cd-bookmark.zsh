function plugin:setup:cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
  unset -f plugin:setup:cdbookmark
}
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \$PWD" atpull"%atclone" atload"plugin:setup:cdbookmark"
zinit light mollifier/cd-bookmark
