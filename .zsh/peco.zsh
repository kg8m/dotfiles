builtin command -v peco > /dev/null || return

# http://k0kubun.hatenablog.com/entry/2014/07/06/033336
# http://blog.livedoor.jp/abell2142/archives/53185576.html
function peco-select-history() {
  typeset tac

  if builtin command -v tac > /dev/null; then
    tac=tac
  elif builtin command -v gtac > /dev/null; then
    tac=gtac
  else
    tac='tail -r'
  fi

  BUFFER=$(history -n 1 | eval $tac | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle -R -c
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# http://k0kubun.hatenablog.com/entry/2014/07/06/033336
function peco-pkill() {
  for pid in `ps aux | peco | awk '{ print $2 }'`; do
    kill $pid
    echo "Killed ${pid}"
  done
}
