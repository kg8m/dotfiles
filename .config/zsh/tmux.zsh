function plugin:tmux:plugins {
  function plugin:tmux:plugins:atclone {
    local plugin_name="$(basename "$1")"
    local plugins_dirpath="${XDG_DATA_HOME:?}/tmux/plugins"
    local plugin_dirpath="${plugins_dirpath}/${plugin_name}"

    mkdir -p "${plugins_dirpath}"

    if [ ! -d "${plugin_dirpath}" ]; then
      ln -s "${PWD}" "${plugin_dirpath}"
    fi
  }

  local plugins=(
    tmux-plugins/tpm
    tmux-plugins/tmux-resurrect
    tmux-plugins/tmux-continuum
    nhdaly/tmux-scroll-copy-mode
  )

  local plugin
  for plugin in "${plugins[@]}"; do
    zinit ice lucid as"null" atclone"plugin:tmux:plugins:atclone ${plugin}"
    zinit light "${plugin}"
  done

  unset -f plugin:tmux:plugins
}
zinit ice lucid nocd wait"0c" atload"plugin:tmux:plugins"
zinit snippet "${XDG_CONFIG_HOME:?}/zsh/null/plugin-tmux-plugins"
