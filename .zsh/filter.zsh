zinit ice lucid wait"0c" pick"shell/completion.zsh"
zinit light junegunn/fzf

function plugin:setup:anyframe {
  autoload -Uz anyframe-init
  anyframe-init

  # `filter` is `.zsh/bin/filter`
  if command -v fzf > /dev/null; then
    source ~/.zsh/env/fzf.zsh
    zstyle ":anyframe:selector:" use fzf
    zstyle ":anyframe:selector:fzf:" command filter
  elif command -v peco > /dev/null; then
    zstyle ":anyframe:selector:" use peco
    zstyle ":anyframe:selector:peco:" command filter
  else
    echo "Any filter is not found." >&2
    return 1
  fi

  bindkey "^R" anyframe-widget-put-history
  unset -f plugin:setup:anyframe
}
zinit ice lucid wait"0c" atload"plugin:setup:anyframe"
zinit light mollifier/anyframe
