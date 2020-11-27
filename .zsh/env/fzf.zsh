# See also `.zsh/filter.zsh`
function plugin:setup:env:fzf {
  # shellcheck disable=SC2034
  local binds=(
    "change:top"
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
    "--bind=${(j:,:)binds}"
    "--exit-0"
    "--info=inline"
    "--multi"
    "--no-sort"
    "--no-unicode"
    "--reverse"
    "--preview='echo {} | head -n3'"
    "--preview-window='down:3:wrap:hidden'"
    "--select-1"
  )

  export FZF_DEFAULT_OPTS="${options[*]}"
  export FZF_DEFAULT_COMMAND="source ~/.zsh/my_functions.zsh; my_grep --files"

  export FZF_VIM_PATH="${VIM_PLUGINS:-}/github.com/junegunn/fzf.vim"

  unset -f plugin:setup:env:fzf
}
plugin:setup:env:fzf
