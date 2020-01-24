function setup_history_substring_search {
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down
}
zinit ice lucid wait atload"setup_history_substring_search"
zinit light zsh-users/zsh-history-substring-search
