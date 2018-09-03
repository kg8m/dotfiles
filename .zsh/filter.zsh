builtin command -v peco > /dev/null || return

export FILTER="peco --rcfile $HOME/.filter/config.json"

fpath=(~/.filter/anyframe(N-/) $fpath)

autoload -Uz anyframe-init
anyframe-init

zstyle ":anyframe:selector:" use peco
zstyle ":anyframe:selector:peco:" command $FILTER

bindkey '^r' anyframe-widget-put-history

alias peco=$FILTER
