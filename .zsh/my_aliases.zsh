alias -g G="| egrep --color=auto"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g F="| filter"

GIT_IGNORE_WHITESPACE_CHANGES=""
GIT_IGNORE_WHITESPACE_CHANGES+=" --ignore-all-space"
GIT_IGNORE_WHITESPACE_CHANGES+=" --ignore-blank-lines"
GIT_IGNORE_WHITESPACE_CHANGES+=" --ignore-space-at-eol"
GIT_IGNORE_WHITESPACE_CHANGES+=" --ignore-space-change"
alias -g GW=$GIT_IGNORE_WHITESPACE_CHANGES
unset GIT_IGNORE_WHITESPACE_CHANGES

AG_OPTIONS=""
AG_OPTIONS+=" --pager=less"
AG_OPTIONS+=" --hidden"
AG_OPTIONS+=" --workers=1"
AG_OPTIONS+=" --color-line-number='1;36'"
AG_OPTIONS+=" --color-match='30;46'"
AG_OPTIONS+=" --color-path='1;34'"
alias ag="ag $AG_OPTIONS"
unset AG_OPTIONS

alias g="git"
alias rm="rm -i"

if `crontab -i > /dev/null 2>&1`; then
  alias crontab="crontab -i"
fi

alias ls="ls --color -a"
alias ll="ls -l --time-style=long-iso"
alias diff="diff -U 10 -b -B"
alias watch="watch --color"

alias reload="source ~/.zshrc; echo \"~/.zshrc sourced.\""

# never use tmuxinator
alias mux="attach_or_new_tmux"
