function setup_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
}

zinit ice lucid wait atload"setup_cdbookmark"; zinit light mollifier/cd-bookmark
