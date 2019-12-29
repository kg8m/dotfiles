function setup_anyframe {
  function setup_fzf {
    local binds=""
    binds+="ctrl-f:page-down"
    binds+=",ctrl-b:page-up"
    binds+=",ctrl-h:backward-char"
    binds+=",ctrl-l:forward-char"
    binds+=",ctrl-space:toggle+down"
    binds+=",tab:toggle-preview"

    local options=""
    options+="--ansi"
    options+=" --bind='$binds'"
    options+=" --exit-0"
    options+=" --multi"
    options+=" --reverse"
    options+=" --preview='echo {}'"
    options+=" --preview-window='down:3:hidden:wrap'"
    options+=" --select-1"

    export FZF_DEFAULT_OPTS="$options"
  }

  autoload -Uz anyframe-init
  anyframe-init

  # `filter` is `.zsh/bin/filter`
  if which fzf > /dev/null 2>&1; then
    setup_fzf
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

zplugin ice lucid wait pick"shell/completion.zsh"; zplugin light junegunn/fzf
zplugin ice lucid wait atload"setup_anyframe"; zplugin light mollifier/anyframe
