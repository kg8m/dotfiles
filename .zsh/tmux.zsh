function setup_my_tmux_plugins {
  function setup_my_tmux_plugin {
    local plugin_name="$( basename "$1" )"

    [ -d ~/.config/tmux ]                        || ln -s ~/dotfiles/.tmux ~/.config/tmux
    [ -d ~/.config/tmux/plugins/"$plugin_name" ] || ln -s "$( pwd )" ~/.config/tmux/plugins/"$plugin_name"

    __setup_done_my_tmux_plugins__+=( "$plugin_name" )

    if [ "${#__setup_done_my_tmux_plugins__[@]}" = "${#__my_tmux_plugins__[@]}" ]; then
      unset __setup_done_my_tmux_plugins__
      unset __my_tmux_plugins__
      unset -f setup_my_tmux_plugin
    fi
  }

  export __setup_done_my_tmux_plugins__=()
  export __my_tmux_plugins__=(
    tmux-plugins/tpm
    tmux-plugins/tmux-resurrect
    tmux-plugins/tmux-continuum
    nhdaly/tmux-scroll-copy-mode
  )

  for plugin in "${__my_tmux_plugins__[@]}"; do
    zinit ice lucid wait"0c" as"null" atload"setup_my_tmux_plugin $plugin"
    zinit light "$plugin"
  done

  unset -f setup_my_tmux_plugins
}

zinit ice lucid nocd wait"0c" atload"setup_my_tmux_plugins"
zinit snippet /dev/null
