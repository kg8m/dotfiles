function plugin:setup:tmux_plugins {
  function plugin:setup:tmux_plugin {
    local plugin_name="$(basename "$1")"
    local tmux_dirpath="${XDG_CONFIG_HOME:?}/tmux"
    local plugins_dirpath="${tmux_dirpath}/plugins"

    [ -d "${tmux_dirpath}" ] || ln -s ~/dotfiles/.config/tmux "${tmux_dirpath}"
    mkdir -p "${plugins_dirpath}"
    [ -d "${plugins_dirpath}/${plugin_name}" ] || ln -s "${PWD}" "${plugins_dirpath}/${plugin_name}"
  }

  local plugins=(
    tmux-plugins/tpm
    tmux-plugins/tmux-resurrect
    tmux-plugins/tmux-continuum
    nhdaly/tmux-scroll-copy-mode
  )

  local plugin
  for plugin in "${plugins[@]}"; do
    zinit ice lucid as"null" atclone"plugin:setup:tmux_plugin ${plugin}"
    zinit light "${plugin}"
  done

  unset -f plugin:setup:tmux_plugins
}
zinit ice lucid nocd wait"0c" pick"/dev/null" atload"plugin:setup:tmux_plugins"
zinit snippet /dev/null
