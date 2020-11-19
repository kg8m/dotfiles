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
zinit ice lucid wait"0c" blockf atpull"zinit creinstall -q \$(pwd)"
zinit light zsh-users/zsh-completions

zinit ice lucid wait"0c" as"completion"
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245,bold"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# https://zdharma.org/zinit/wiki/Example-Minimal-Setup/
zinit ice lucid wait"0c" atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions
