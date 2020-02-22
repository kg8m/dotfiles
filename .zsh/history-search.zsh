function setup_my_history_substring_search {
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down
}
zinit ice lucid wait"!0a" atload"setup_my_history_substring_search"
zinit light zsh-users/zsh-history-substring-search
