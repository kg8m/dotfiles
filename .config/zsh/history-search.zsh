# up-line-or-beginning-search, down-line-or-beginning-search
#   These widgets are similar to the builtin functions up-line-or-search and down-line-or-search: if in a multiline
#   buffer they move up or down within the buffer, otherwise they search for a history line matching the start of the
#   current line. In this case, however, they search for a line which matches the current line up to the current cursor
#   position, in the manner of history-beginning-search-backward and -forward, rather than the first word on the line.
# (source: man zshcontrib)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

function plugin:fzf_history_search:atload {
  export ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS="--preview-window down:5:wrap:nohidden"
  export ZSH_FZF_HISTORY_SEARCH_END_OF_LINE="1"
  export ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS="0"
  export ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH="0"
}
zinit ice lucid trigger-load!"fzf_history_search" atload"plugin:fzf_history_search:atload"
zinit light joshskidmore/zsh-fzf-history-search
PLUGINS_FOR_TRIGGER_LOAD+=("joshskidmore/zsh-fzf-history-search")

zle -N fzf_history_search
bindkey "^R" fzf_history_search
