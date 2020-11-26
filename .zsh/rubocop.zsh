# Don't use zinit's options like `as"command" pick"bin/rubocop-daemon-wrapper"` because it makes the `$PATH` longer and
# longer. Make symbolic links in `$HOME/bin` instead.
function setup_my_rubocop_daemon {
  local binary="bin/rubocop-daemon-wrapper"

  mkdir -p "$HOME/bin"
  ln -fs "$PWD/${binary}" "$HOME/bin/$(basename "$binary")"
}
zinit ice lucid wait"0c" as"null" atclone"setup_my_rubocop_daemon"
zinit light fohte/rubocop-daemon
