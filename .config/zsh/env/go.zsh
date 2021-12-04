function() {
  if [ ! -f "${KG8M_ZSH_CACHE_DIR:?}/gopath" ]; then
    # Depend on goenv; see also `.config/zsh/goenv.zsh`
    find ~/go -maxdepth 1 -mindepth 1 -type d | sort --version-sort | tail -n1 > "${KG8M_ZSH_CACHE_DIR}/gopath"
  fi
  local gopath="$(cat "${KG8M_ZSH_CACHE_DIR}/gopath")"

  if [ -n "${gopath}" ] && [ -d "${gopath}/bin" ]; then
    path+=("${gopath}/bin")
  fi
}
