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
    "--bind '${(j:,:)binds}'"

    # https://github.com/junegunn/fzf/wiki/Color-schemes
    "--color 'fg+:bold:230'"

    "--exact"
    "--exit-0"
    "--highlight-line"
    "--info inline"
    "--multi"
    "--no-sort"
    "--reverse"
    "--preview 'echo {} | head -n3'"
    "--preview-window 'down:5:wrap'"
    "--scroll-off 15"
    "--select-1"
    "--track"
  )

  # $FD_EXTRA_OPTIONS is a string because direnv doesn’t support arrays.
  export FZF_DEFAULT_OPTS="${options[*]}"
  export FZF_DEFAULT_COMMAND="fd \"\${FD_DEFAULT_OPTIONS[@]:?}\" \${=FD_EXTRA_OPTIONS} --strip-cwd-prefix --type file --color always | sort_without_escape_sequences"

  # Use fzf with full height. fzf’s default (40%) is too small.
  export FZF_TMUX_HEIGHT="~100"
}
