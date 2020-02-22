function setup_my_anyframe {
  autoload -Uz anyframe-init
  anyframe-init

  # `filter` is `.zsh/bin/filter`
  if which fzf > /dev/null 2>&1; then
    source ~/.zsh/env/fzf.zsh
    zstyle ":anyframe:selector:" use fzf
    zstyle ":anyframe:selector:fzf:" command filter
  elif which peco > /dev/null 2>&1; then
    zstyle ":anyframe:selector:" use peco
    zstyle ":anyframe:selector:peco:" command filter
  else
    echo "Any filter is not found." >&2; return 1
  fi

  bindkey "^R" anyframe-widget-put-history
}

zinit ice lucid wait"!0a" pick"shell/completion.zsh"; zinit light junegunn/fzf
zinit ice lucid wait"!0a" atload"setup_my_anyframe"; zinit light mollifier/anyframe
