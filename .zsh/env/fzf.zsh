# See also `.zsh/filter.zsh`
function setup_my_fzf {
  local binds=""
  binds+="ctrl-f:page-down"
  binds+=",ctrl-b:page-up"
  binds+=",ctrl-h:backward-char"
  binds+=",ctrl-l:forward-char"
  binds+=",ctrl-space:toggle+down"
  binds+=",tab:toggle-preview"
  binds+=",ctrl-j:preview-down"
  binds+=",ctrl-k:preview-up"

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
  export FZF_DEFAULT_COMMAND="source ~/.zsh/my_functions.zsh; my_grep --files"

  unset -f setup_my_fzf
}
setup_my_fzf
