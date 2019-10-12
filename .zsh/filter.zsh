zplugin light mollifier/anyframe

autoload -Uz anyframe-init
anyframe-init

zstyle ":anyframe:selector:" use peco
zstyle ":anyframe:selector:peco:" command filter

bindkey "^R" anyframe-widget-put-history
