function setup_my_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
  unset -f setup_my_cdbookmark
}
zinit ice lucid wait"!0a" blockf atpull"zinit creinstall -q ." atload"setup_my_cdbookmark"
zinit light mollifier/cd-bookmark
