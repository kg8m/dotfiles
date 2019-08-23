which peco > /dev/null 2>&1 || return

fpath=(~/.filter/anyframe(N-/) $fpath)

autoload -Uz anyframe-init
anyframe-init

zstyle ":anyframe:selector:" use peco
zstyle ":anyframe:selector:peco:" command filter

bindkey '^r' anyframe-widget-put-history
