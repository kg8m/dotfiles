function setup_anyframe {
  autoload -Uz anyframe-init
  anyframe-init

  if which fzf > /dev/null 2>&1; then
    local fzf_binds=""
    fzf_binds+="ctrl-f:page-down"
    fzf_binds+=",ctrl-b:page-up"
    fzf_binds+=",ctrl-space:toggle+down"
    fzf_binds+=",ctrl-h:backward-char"
    fzf_binds+=",ctrl-l:forward-char"
    export FZF_DEFAULT_OPTS="--ansi --multi --bind=$fzf_binds"

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

zplugin ice lucid wait atload"setup_anyframe"; zplugin light mollifier/anyframe
