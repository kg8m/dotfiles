alias -g G="| egrep --color=always"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g F="| \$FILTER"
alias -g GW="--ignore-all-space --ignore-blank-lines --ignore-space-at-eol --ignore-space-change"  # for Git: ignore whitespace changes

alias ag="ag --pager=less --hidden --color-line-number='1;36' --color-match='30;46' --color-path='1;34'"
alias g="git"
alias rm="rm -i"

if `crontab -i > /dev/null 2>&1`; then
  alias crontab="crontab -i"
fi

alias ls="ls --color -a"
alias ll="ls -l --time-style=long-iso"
alias diff="diff -U 10 -b -B"
alias watch="watch --color"

alias reload="source ~/.zshrc; echo "~/.zshrc sourced.""

alias mux='attach_or_new_tmux'  # never use tmuxinator
