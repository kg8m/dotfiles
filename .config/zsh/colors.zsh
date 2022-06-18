function plugin:dircolors:atload {
  if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/dircolors_ansi-universal" ]; then
    local tempfile="$(mktemp)"

    cat dircolors.ansi-universal > "${tempfile}"

    # shellcheck disable=SC2034
    local overwrites=(
      # gray
      ".DS_Store 38;5;245"
      ".example 38;5;245"

      # green: editable text
      ".diff 32"
      ".jb 32"
      ".json 32"
      ".jsx 32"
      ".rake 32"
      ".slim 32"
      ".toml 32"
      ".ts 32"
      ".tsx 32"
      ".vimrc 32"
      ".vue 32"
      ".yaml 32"
      ".yml 32"
      ".zshenv 32"
      ".zshenv.local 32"
      ".zshrc 32"
      ".zshrc.local 32"
    )

    echo "${(j:\n:)overwrites}" >> "${tempfile}"

    if command -v gdircolors > /dev/null; then
      local dircolors=gdircolors
    else
      local dircolors=dircolors
    fi

    "${dircolors}" "${tempfile}" > "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
    rm -f "${tempfile}"

    zcompile "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
  fi
  source "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
  zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

  unset -f plugin:dircolors:atload
}

function plugin:dircolors:atclone {
  echo -e "\n$(highlight:yellow "Reset colors, so check updates and fix my overwrites if needed.")\n"
  trash "${KG8M_ZSH_CACHE_DIR:?}/dircolors_ansi-universal"
}

zinit ice lucid wait"0c" atclone="plugin:dircolors:atclone" atpull="%atclone" atload"plugin:dircolors:atload"
zinit light seebi/dircolors-solarized
