zplugin ice silent wait; zplugin light zsh-users/zsh-completions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Don't use `zplugin ice wait` because it prevents autosuggestions startup
zplugin light zsh-users/zsh-autosuggestions
