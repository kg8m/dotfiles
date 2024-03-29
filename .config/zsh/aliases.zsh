alias -g G="| rg --color auto"
alias -g V="| vim -R -"
alias -g L="| less"
alias -g H="| head"
alias -g T="| tail"
alias -g F="| filter"
alias -g S="| sort_without_escape_sequences"

if crontab -i > /dev/null 2>&1; then
  alias crontab="crontab -i"
fi

# shellcheck disable=SC2154
# $FD_EXTRA_OPTIONS is a string because direnv doesn't support arrays.
alias fd="fd \${FD_DEFAULT_OPTIONS:?[@]} \${(s: :)FD_EXTRA_OPTIONS}"
alias rm="rm -i"

# Don't inherit `$TERM` to remote servers.
# `xterm-256color-italic` is set in tmux.
alias ssh="TERM=xterm-256color ssh"

# - Specify `-H` (Home): set the `HOME` environment variable to root user’s one.
# - Specify `-E` (Environment): preserve environment variables.
# - End with a whitespace in order to expand my aliases via sudo.
#   cf. https://qiita.com/homoluctus/items/ba1a6d03df85e65fc85a
alias sudo="sudo -H -E "

alias watch="watch --color"
