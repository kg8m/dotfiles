builtin command -v peco > /dev/null || return

filter_path=~/bin/filter

# https://qiita.com/mollifier/items/1c4a4930a89aa75e5ced
if [ -f $filter_path(m+1) ]; then
  echo "Remove $filter_path because it is too old"
  execute_with_echo "mv $filter_path /tmp/filter.bak.$( date +%Y%m%d )"
fi

if [ ! -f $filter_path ]; then
  echo "Create $filter_path"
  echo "#!/usr/bin/env zsh" >> $filter_path
  echo "peco --rcfile ~/.filter/config.json" >> $filter_path
  chmod +x $filter_path
fi

unset filter_path

fpath=(~/.filter/anyframe(N-/) $fpath)

autoload -Uz anyframe-init
anyframe-init

zstyle ":anyframe:selector:" use peco
zstyle ":anyframe:selector:peco:" command filter

bindkey '^r' anyframe-widget-put-history
