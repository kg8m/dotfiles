function setup_anyframe {
  autoload -Uz anyframe-init
  anyframe-init

  zstyle ":anyframe:selector:" use peco
  zstyle ":anyframe:selector:peco:" command filter

  bindkey "^R" anyframe-widget-put-history
}

zplugin ice lucid wait atload"setup_anyframe"; zplugin light mollifier/anyframe
