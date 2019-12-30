function setup_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
}

zplugin ice lucid wait'[[ -n ${ZLAST_COMMANDS[(r)cdb*]} ]]' atload"setup_cdbookmark"
zplugin light mollifier/cd-bookmark
