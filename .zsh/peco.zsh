builtin command -v peco > /dev/null || return

fpath=(~/.peco/anyframe(N-/) $fpath)

autoload -Uz anyframe-init
anyframe-init

bindkey '^r' anyframe-widget-put-history

# "Layout" setting in configuration file not working
zstyle ':anyframe:selector:peco:' command 'peco --layout bottom-up'
alias peco='peco --layout bottom-up'
