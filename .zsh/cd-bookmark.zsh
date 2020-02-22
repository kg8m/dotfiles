function setup_my_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
}

zinit ice lucid wait blockf atpull"zinit creinstall -q ." atload"setup_my_cdbookmark"
zinit light mollifier/cd-bookmark
