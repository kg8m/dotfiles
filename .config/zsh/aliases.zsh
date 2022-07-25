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
# shellcheck disable=SC2154
alias fd="fd \${FD_DEFAULT_OPTIONS:?[@]}"
alias ls="ls --color --almost-all"
alias ll="ls -l --time-style=long-iso"
alias rm="rm -i"

# Don't inherit `$TERM` to remote servers.
# `xterm-256color-italic` is set in tmux.
alias ssh="TERM=xterm-256color ssh"

# Specify `-E` because sudo sometimes doesn't know my special commands/aliases.
# End with a whitespace in order to expand my aliases via sudo.
#   cf. https://qiita.com/homoluctus/items/ba1a6d03df85e65fc85a
alias sudo="sudo -E "

alias watch="watch --color"
