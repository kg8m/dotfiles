zinit ice lucid wait"0c" pick"shell/completion.zsh"
zinit light junegunn/fzf

function plugin:setup:anyframe {
  autoload -U anyframe-init
  anyframe-init

  # `filter` is `.config/zsh/bin/filter`
  if command -v fzf > /dev/null; then
    source ~/.config/zsh/env/fzf.zsh
    zstyle ":anyframe:selector:" use fzf
    zstyle ":anyframe:selector:fzf:" command filter
  else
    echo:warn "Any filter is not found."
    return 1
  fi

  bindkey "^R" anyframe-widget-put-history
  unset -f plugin:setup:anyframe
}
zinit ice lucid wait"0c" atload"plugin:setup:anyframe"
zinit light mollifier/anyframe
