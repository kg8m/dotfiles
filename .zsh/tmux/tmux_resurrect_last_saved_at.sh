find ~/.tmux/resurrect/last -ls |
  awk '{print $NF}' |
  grep -E '[0-9]{4}-?[0-9]{2}-?[0-9]{2}T[0-9]{2}:?[0-9]{2}' -o |
  sed \
    -e 's/T/ /' \
    -e 's/-/\//g' \
    -e 's/\([0-9]\{4\}\)\([0-9][0-9]\)/\1\/\2\//' \
    -e 's/\([0-9][0-9]\)\([0-9][0-9]\)$/\1:\2/'
