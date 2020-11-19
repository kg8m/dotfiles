function setup_my_tmux_plugins {
  function setup_my_tmux_plugin {
    local plugin_name="$(basename "$1")"

    [ -d ~/.config/tmux ]                        || ln -s ~/dotfiles/.tmux ~/.config/tmux
    [ -d ~/.config/tmux/plugins/"$plugin_name" ] || ln -s "$(pwd)" ~/.config/tmux/plugins/"$plugin_name"

    __setup_done_my_tmux_plugins__+=("$plugin_name")

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

case "$-" in
  *i*)  # Interactive shell
    if [ -n "${TMUX:-}" ]; then
      function tmux_save_pane_logs_automatically {
        local DIRPATH="$HOME/tmp/tmux-logs"
        local FILENAME="$(tmux run-shell "echo tmux-#{session_name}-#{window_index}-#{pane_index}.log")"

        if echo | sed -r > /dev/null 2>&1; then
          local sed="sed -r"
        else
          local sed="sed -E"
        fi

        mkdir -p "$DIRPATH"

        # Remove escape sequences
        # https://stackoverflow.com/questions/17998978/removing-colors-from-output
        # https://stackoverflow.com/questions/19296667/remove-ansi-color-codes-from-a-text-file-using-bash
        tmux pipe-pane "cat | $sed 's/[[:cntrl:]]\\[([0-9]{1,3}(;[0-9]{1,3}){0,4})?[fmGHJK]//g' >> '$DIRPATH/$FILENAME'"

        unset -f tmux_save_pane_logs_automatically
      }
      zinit ice lucid nocd wait"0c" atload"tmux_save_pane_logs_automatically"
      zinit snippet /dev/null
    fi
    ;;
  *)  # Non interactive shell
    ;;
esac
