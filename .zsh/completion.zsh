# http://voidy21.hatenablog.jp/entry/20090902/1251918174
# https://qiita.com/kotashiratsuka/items/ae37757aa1d31d1d4f4d
zstyle ':completion:*' menu select=1
zstyle ':completion:*' completer _complete _match _approximate _list _history
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' use-cache true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt complete_in_word

# https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
zinit ice lucid wait"!0c" blockf atpull"zinit creinstall -q ."
zinit light zsh-users/zsh-completions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
# Load before zsh-history-substring-search
zinit ice lucid wait"!0b" atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

function setup_my_fzf_tab {
  # See also fzf's configs in .zsh/filter.zsh
  export fzf_default_completion=fzf-tab-complete
  unset -f setup_my_fzf_tab
}
# Load before zsh-autosuggestions
zinit ice lucid wait"!0a" atload"setup_my_fzf_tab"
zinit light Aloxaf/fzf-tab
