function setup_my_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
  unset -f setup_my_cdbookmark
}
zinit ice lucid wait"0c" blockf atclone"zinit creinstall \$PWD" atpull"%atclone" atload"setup_my_cdbookmark"
zinit light mollifier/cd-bookmark
