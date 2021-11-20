function plugin:setup:dircolors {
  if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/dircolors_ansi-universal" ]; then
    local tempfile="$(mktemp)"

    cat dircolors.ansi-universal > "${tempfile}"

    # shellcheck disable=SC2034
    local overwrites=(
      # bright black (gray)
      ".DS_Store 01;30"
      ".example 01;30"

      # green: editable text
      ".diff 32"
      ".json 32"
      ".toml 32"
      ".ts 32"
      ".vimrc 32"
      ".vue 32"
      ".yaml 32"
      ".yml 32"
      ".zshenv 32"
      ".zshrc 32"
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

  unset -f plugin:setup:dircolors
}

function plugin:setup:dircolors:reset {
  echo -e "\n$(highlight:yellow "Reset colors, so check updates and fix my overwrites if needed.")\n"
  trash "${KG8M_ZSH_CACHE_DIR:?}/dircolors_ansi-universal"
}

zinit ice lucid wait"0c" atclone="plugin:setup:dircolors:reset" atpull="%atclone" atload"plugin:setup:dircolors"
zinit light seebi/dircolors-solarized
