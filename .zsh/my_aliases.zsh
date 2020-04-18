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
alias sudo='sudo env PATH=$PATH'
alias watch="watch --color"

alias reload="source ~/.zshrc; echo \"~/.zshrc sourced.\""

# Never use tmuxinator
alias mux="attach_or_new_tmux"
