builtin command -v peco > /dev/null || return

fpath=(~/.peco/anyframe(N-/) $fpath)

autoload -Uz anyframe-init
anyframe-init

bindkey '^r' anyframe-widget-put-history
