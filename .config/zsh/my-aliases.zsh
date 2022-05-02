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
alias ls="ls --color --almost-all -v"
alias ll="ls -l --time-style=long-iso"
alias rm="rm -i"

# Don't inherit `$TERM` to remote servers.
# `xterm-256color-italic` is set in tmux.
alias ssh="TERM=xterm-256color ssh"

# Specify PATH because sudo sometimes doesn't know my special paths.
# End with a whitespace in order to expand my aliases via sudo.
#   cf. https://qiita.com/homoluctus/items/ba1a6d03df85e65fc85a
alias sudo='sudo env PATH=${PATH} '

alias watch="watch --color"

if [ -n "${ZABRZE_UNAVAILABLE}" ]; then
  function plugin:init:abbr {
    # Silence "Added the global session abbreviation `foo`" messages.
    export ABBR_QUIET="1"

    # Prevent "_abbr_global_expansion:source:12: no such file or directory:
    # /var/folders/foo/bar/baz/zsh-abbr/global-user-abbreviations" error after long sleep of OS.
    export ABBR_TMPDIR="${XDG_CACHE_HOME:?}/zsh/abbr/"

    # Instead of `${XDG_CONFIG_HOME}/zsh/abbreviations`
    export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CACHE_HOME:?}/zsh/abbreviations"
  }

  function plugin:setup:abbr {
    abbr --session --force --global g="git"
    abbr --session --force --global r="rails"
    abbr --session --force --global v="vim"

    # Use `--quieter` option to silence "`vi` will now expand as an abbreviation" warning when overwriting system `vi`
    # command.
    abbr --session --force --global --quieter vi="vim"

    abbr --session --force bmv="batch_move"
    abbr --session --force cdb="cd-bookmark"
    abbr --session --force gr="my_grep:with_filter"
    abbr --session --force t="tmux:attach_or_new"

    unset -f plugin:setup:abbr
  }
  zinit ice lucid wait"0a" atinit"plugin:init:abbr" atload"plugin:setup:abbr"
  zinit light olets/zsh-abbr
fi
