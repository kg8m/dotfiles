alias -g G="| rg --color auto"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g F="| filter"

if crontab -i > /dev/null 2>&1; then
  alias crontab="crontab -i"
fi

alias diff="diff -U 10 -b -B"
alias ls="ls --color -a"
alias ll="ls -l --time-style=long-iso"
alias rm="rm -i"

# Don't inherit `$TERM` to remote servers.
# `xterm-256color-italic` is set in tmux.
alias ssh="TERM=xterm-256color ssh"

alias sudo='sudo env PATH=$PATH'
alias watch="watch --color"

function plugin:setup:abbr {
  abbr --session --quiet --force --global g="git"
  abbr --session --quiet --force --global v="vim"
  abbr --session --quiet --force --global vi="vim"

  unset -f plugin:setup:abbr
}
zinit ice lucid wait"0c" atload"plugin:setup:abbr"
zinit light olets/zsh-abbr
