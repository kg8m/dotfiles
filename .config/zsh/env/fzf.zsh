# See also `.config/zsh/filter.zsh`
function() {
  local alt_a="å"
  local alt_b="∫"
  local alt_f="ƒ"
  local alt_j="∆"
  local alt_k="˚"
  local alt_n="˜"
  local alt_p="π"

  # shellcheck disable=SC2034
  local binds=(
    "change:top"

    "${alt_f}:page-down"
    "${alt_b}:page-up"

    "${alt_a}:toggle-all"
    "ctrl-space:toggle+down"

    "tab:toggle-preview"
    "${alt_j}:preview-down"
    "${alt_n}:preview-down"
    "${alt_k}:preview-up"
    "${alt_p}:preview-up"
  )

  local options=(
    "--ansi"
    "--bind=${(j:,:)binds}"
    "--exact"
    "--exit-0"
    "--info=inline"
    "--multi"
    "--no-sort"
    "--reverse"
    "--preview='echo {} | head -n3'"
    "--preview-window='down:5:wrap:hidden'"
    "--select-1"
  )

  export FZF_DEFAULT_OPTS="${options[*]}"
  export FZF_DEFAULT_COMMAND="source ~/.config/zsh/my-functions.zsh; my_grep --files"

  export FZF_VIM_PATH="${VIM_PLUGINS:?}/github.com/junegunn/fzf.vim"
}
