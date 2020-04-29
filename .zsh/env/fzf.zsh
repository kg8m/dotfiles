# See also `.zsh/filter.zsh`
function setup_my_fzf {
  local binds=(
    "ctrl-f:page-down"
    "ctrl-b:page-up"
    "ctrl-h:backward-char"
    "ctrl-l:forward-char"
    "ctrl-space:toggle+down"
    "tab:toggle-preview"
    "ctrl-j:preview-down"
    "ctrl-k:preview-up"
  )

  local options=(
    "--ansi"
    "--bind='${(j:,:)binds}'"
    "--exit-0"
    "--info=inline"
    "--multi"
    "--no-sort"
    "--no-unicode"
    "--reverse"
    "--preview='echo {} | head -n3'"
    "--preview-window='down:3:hidden:wrap'"
    "--select-1"
  )

  export FZF_DEFAULT_OPTS="${options[*]}"
  export FZF_DEFAULT_COMMAND="source ~/.zsh/my_functions.zsh; my_grep --files"

  unset -f setup_my_fzf
}
setup_my_fzf
