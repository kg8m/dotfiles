function plugin:setup:dircolors {
  if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/dircolors_ansi-universal" ]; then
    if command -v gdircolors > /dev/null; then
      local dircolors=gdircolors
    else
      local dircolors=dircolors
    fi

    # My original colors:
    #   export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
    #   export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
    #   zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'
    $dircolors dircolors.ansi-universal > "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
    zcompile "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
  fi
  source "${KG8M_ZSH_CACHE_DIR}/dircolors_ansi-universal"
  zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

  unset -f plugin:setup:dircolors
}
zinit ice lucid wait"0c" atload"plugin:setup:dircolors"
zinit light seebi/dircolors-solarized
