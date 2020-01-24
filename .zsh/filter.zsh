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
    options+=" --ansi"
    options+=" --bind='$binds'"
    options+=" --exit-0"
    options+=" --info=inline"
    options+=" --multi"
    options+=" --no-sort"
    options+=" --no-unicode"
    options+=" --reverse"
    options+=" --preview='echo {} | head -n3'"
    options+=" --preview-window='down:3:hidden:wrap'"
    options+=" --select-1"

    export FZF_DEFAULT_OPTS="$options"
    export FZF_DEFAULT_COMMAND="source ~/.zsh/my_functions.zsh; my_grep_without_pager --files"
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

zinit ice lucid wait pick"shell/completion.zsh"; zinit light junegunn/fzf
zinit ice lucid wait atload"setup_anyframe"; zinit light mollifier/anyframe
