# http://voidy21.hatenablog.jp/entry/20090902/1251918174
# https://qiita.com/kotashiratsuka/items/ae37757aa1d31d1d4f4d
zstyle ':completion:*' menu select=1
zstyle ':completion:*' completer _complete _match _approximate _list _history
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' use-cache true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Also see `export LSCOLORS/LS_COLORS`
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'

setopt complete_in_word

zplugin ice lucid wait; zplugin light zsh-users/zsh-completions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245,bold"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Don't use `zplugin ice wait` because it prevents autosuggestions startup
zplugin light zsh-users/zsh-autosuggestions
