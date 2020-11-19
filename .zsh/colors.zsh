function setup_my_dircolors {
  if command -v gdircolors > /dev/null 2>&1; then
    local dircolors=gdircolors
  else
    local dircolors=dircolors
  fi

  if ! [ -f "${KGYM_ZSH_CACHE_DIR:-}/dircolors_ansi-universal" ]; then
    # My original colors:
    #   export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
    #   export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
    #   zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'
    $dircolors dircolors.ansi-universal > "$KGYM_ZSH_CACHE_DIR/dircolors_ansi-universal"
    zcompile "$KGYM_ZSH_CACHE_DIR/dircolors_ansi-universal"
  fi
  source "$KGYM_ZSH_CACHE_DIR/dircolors_ansi-universal"
  zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

  unset -f setup_my_dircolors
}
zinit ice lucid wait"0c" atload"setup_my_dircolors"
zinit light seebi/dircolors-solarized
