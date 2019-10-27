function setup_history_substring_search {
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down
}
zplugin ice lucid wait atload"setup_history_substring_search"
zplugin light zsh-users/zsh-history-substring-search
