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
zinit ice lucid wait"!0c" atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

function prepare_my_fzf_tab {
  source ~/.zsh/env/fzf.zsh

  # Overwrite default FZF_TAB_OPTS
  # https://github.com/Aloxaf/fzf-tab/blob/607a28b8950a152e3e799799c45c1110d10e680f/fzf-tab.zsh#L95-L104
  # https://github.com/Aloxaf/fzf-tab/issues/31#issuecomment-583725757
  FZF_TAB_OPTS=(
    --expect="/"                  # For continuous completion
    --nth=2,3 --delimiter='\x00'  # Don't search prefix
    '--query=$query'              # $query will be expanded to query string at runtime.
    '--header-lines=$#headers'    # $#headers will be expanded to lines of headers at runtime
    "${FZF_DEFAULT_OPTS_ARRAY[(r)--bind=*]},tab:down,btab:up,change:top"
  )
}
function setup_my_fzf_tab {
  # See also fzf's configs in .zsh/filter.zsh
  export fzf_default_completion=fzf-tab-complete
  unset -f setup_my_fzf_tab
}
# Load before zsh-autosuggestions
zinit ice lucid wait"!0b" atinit"prepare_my_fzf_tab" atload"setup_my_fzf_tab"
zinit light Aloxaf/fzf-tab
