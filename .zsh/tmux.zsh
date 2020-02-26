# https://gist.github.com/acdvorak/060150b5334999b563eb
function tmux_execute_in_all_panes {
  # Assign the argument to something readable
  local COMMAND=$1

  # Remember which window/pane we were originally at
  local ORIG_WINDOW_INDEX=`tmux display-message -p '#I'`
  local ORIG_PANE_INDEX=`tmux display-message -p '#P'`

  # Loop through the windows
  for WINDOW in `tmux list-windows -F '#I'`; do
    # Select the window
    tmux select-window -t $WINDOW

    # Remember the window's current pane sync setting
    local ORIG_PANE_SYNC=`tmux show-window-options | grep '^synchronize-panes' | awk '{ print $2 }'`

    # Send keystrokes to all panes within the current window simultaneously
    tmux set-window-option synchronize-panes on

    # Send the escape key in case we are in a vim-like program.  This is
    # repeated because the send-key command is not waiting for vim to complete
    # its action...  And sending a `sleep 1` command seems to screw up the loop.
    for i in {1..25}; do tmux send-keys 'C-['; done

    # Temporarily suspend any GUI that's running
    tmux send-keys C-z

    # If no GUI was running, kill any input the user may have typed on the
    # command line to avoid A) concatenating our command with theirs, and
    # B) accidentally running a command the user didn't want to run
    # (e.g., rm -rf ~).
    tmux send-keys C-c

    # Run the command and switch back to the GUI if there was any
    tmux send-keys "$COMMAND; fg 2>/dev/null; echo -n" C-m

    # Restore the window's original pane sync setting
    if [[ -n "$ORIG_PANE_SYNC" ]]; then
      tmux set-window-option synchronize-panes "$ORIG_PANE_SYNC"
    else
      tmux set-window-option -u synchronize-panes
    fi
  done

  # Select the original window and pane
  tmux select-window -t $ORIG_WINDOW_INDEX
  tmux select-pane -t $ORIG_PANE_INDEX
}

function setup_my_tmux_plugin {
  [ -d ~/.tmux ]            || ln -s ~/dotfiles/.tmux ~/.tmux
  [ -d ~/.tmux/plugins/"$1" ] || ln -s "$( pwd )" ~/.tmux/plugins/"$1"
  [ "$( /bin/ls ~/.tmux/plugins/ | wc -l )" -eq "4" ] && unset -f setup_my_tmux_plugin
}

zinit ice lucid wait"!0a" as"null" atload"setup_my_tmux_plugin tpm"
zinit light tmux-plugins/tpm

zinit ice lucid wait"!0a" as"null" atload"setup_my_tmux_plugin tmux-resurrect"
zinit light tmux-plugins/tmux-resurrect

zinit ice lucid wait"!0a" as"null" atload"setup_my_tmux_plugin tmux-continuum"
zinit light tmux-plugins/tmux-continuum

zinit ice lucid wait"!0a" as"null" atload"setup_my_tmux_plugin tmux-scroll-copy-mode"
zinit light nhdaly/tmux-scroll-copy-mode
