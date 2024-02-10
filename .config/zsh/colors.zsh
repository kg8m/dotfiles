function plugin:dircolors:atload {
  if [ ! -f "${XDG_CACHE_HOME:?}/zsh/dircolors_ansi-universal.zsh" ]; then
    local tempfile="$(mktemp)"

    cat dircolors.ansi-universal > "${tempfile}"

    # shellcheck disable=SC2034
    local overwrites=(
      # gray
      ".DS_Store 38;5;245"
      ".example 38;5;245"

      # green: editable text
      ".conf 32"
      ".ctags 32"
      ".diff 32"
      ".envrc 32"
      ".gemrc 32"
      ".gitignore 32"
      ".gitmodules 32"
      ".irbrc 32"
      ".jb 32"
      ".jq 32"
      ".json 32"
      ".jsx 32"
      ".rake 32"
      ".slim 32"
      ".snip 32"
      ".toml 32"
      ".ts 32"
      ".tsx 32"
      ".vimrc 32"
      ".vue 32"
      ".yaml 32"
      ".yml 32"
      ".zshenv 32"
      ".zshrc 32"
    )

    echo "${(j:\n:)overwrites}" >> "${tempfile}"

    if ((${+commands[gdircolors]})); then
      local dircolors=gdircolors
    else
      local dircolors=dircolors
    fi

    "${dircolors}" "${tempfile}" > "$(ensure_dir "${XDG_CACHE_HOME}/zsh/dircolors_ansi-universal.zsh")"
    rm -f "${tempfile}"

    # cf. zsh:rcs:compile() and zsh:rcs:compile:clear()
    zcompile "${XDG_CACHE_HOME}/zsh/dircolors_ansi-universal.zsh"
  fi
  source "${XDG_CACHE_HOME}/zsh/dircolors_ansi-universal.zsh"
  zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

  unset -f plugin:dircolors:atload
}

function plugin:dircolors:atclone {
  rm -f "${XDG_CACHE_HOME:?}/zsh/dircolors_ansi-universal.zsh"
  echo
  echo:info "Dircolors have updated. So check them and fix my overwrites in \`plugin:dircolors:atload\` if needed."
  echo
}

zinit ice lucid wait"0c" atclone="plugin:dircolors:atclone" atpull="%atclone" atload"plugin:dircolors:atload"
zinit light seebi/dircolors-solarized
