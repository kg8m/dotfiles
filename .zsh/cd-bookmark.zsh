function setup_cdbookmark {
  autoload -Uz cd-bookmark
  alias cdb="cd-bookmark"
}

zplugin ice silent wait atload"setup_cdbookmark"; zplugin light mollifier/cd-bookmark
