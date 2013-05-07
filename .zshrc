# http://news.mynavi.jp/column/zsh/024/
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

if [ -e ~/svn_editor.sh ]; then
  export SVN_EDITOR="sh ~/svn_editor.sh"
else
  export SVN_EDITOR=vim
fi

export GIT_EDITOR=vim
export RUBYGEMS_PATH='/usr/local/lib/ruby/gems/1.8/gems/'

HISTFILE=~/.zsh_histfile
HISTSIZE=100000
SAVEHIST=100000

autoload -U compinit
compinit

bindkey -v

# http://blog.blueblack.net/item_204
setopt prompt_subst                          # 色を使う
setopt nobeep                                # ビープを鳴らさない
setopt long_list_jobs                        # 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt list_types                            # 補完候補一覧でファイルの種別をマーク表示
setopt auto_resume                           # サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_list                             # 補完候補を一覧表示
setopt hist_ignore_dups                      # 直前と同じコマンドをヒストリに追加しない
setopt auto_pushd                            # cd 時に自動で push
setopt pushd_ignore_dups                     # 同じディレクトリを pushd しない
setopt extended_glob                         # ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt auto_menu                             # TAB で順に補完候補を切り替える
setopt extended_history                      # zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt equals                                # =command を command のパス名に展開する
setopt magic_equal_subst                     # --prefix=/usr などの = 以降も補完
setopt hist_verify                           # ヒストリを呼び出してから実行する間に一旦編集
setopt numeric_glob_sort                     # ファイル名の展開で辞書順ではなく数値的にソート
setopt print_eight_bit                       # 出力時8ビットを通す
setopt share_history                         # ヒストリを共有
zstyle ':completion:*:default' menu select=1 # 補完候補のカーソル選択を有効に
setopt auto_cd                               # ディレクトリ名だけで cd
setopt auto_param_keys                       # カッコの対応などを自動的に補完
setopt auto_param_slash                      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt correct                               # スペルチェック
setopt brace_ccl                             # {a-c} を a b c に展開する機能を使えるようにする
setopt NO_flow_control                       # Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt hist_ignore_space                     # コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt interactive_comments                  # コマンドラインでも # 以降をコメントと見なす
setopt mark_dirs                             # ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt hist_no_store                         # history (fc -l) コマンドをヒストリリストから取り除く。
setopt list_packed                           # 補完候補を詰めて表示
setopt noautoremoveslash                     # 最後のスラッシュを自動的に削除しない

# follow original file/directory via symbolic link
setopt chase_links

# prevent careless logout
setopt ignore_eof

# completion candidates include aliases
setopt complete_aliases

# https://github.com/Shougo/shougo-s-github/blob/master/.zshrc
zstyle ':completion:*' matcher-list \
       '' \
       'm:{a-z}={A-Z}' \
       'l:|=* r:|[.,_-]=* r:|=* m:{a-z}={A-Z}'

# http://d.hatena.ne.jp/tarao/20100531/1275322620
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' completer _oldlist _complete _match _ignored _approximate _list _history

# http://d.hatena.ne.jp/mollifier/20101227/p1
autoload -Uz zmv

# http://subtech.g.hatena.ne.jp/secondlife/20110222/1298354852
# <C-r> for incremental history search
# wild cards enabled
bindkey '^R' history-incremental-pattern-search-backward

# http://news.mynavi.jp/column/zsh/004/
# search command history
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# http://blog.w32.jp/2012/09/zsh.html
# ignore particular commands from history
zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}

  [[   ${cmd} != (rm)
    && ${cmd} != (cap)
    && ${cmd} != (rake)
  ]]
}

# http://blog.blueblack.net/item_207
# prompt styles
autoload colors
colors
PROMPT2="%{${fg[green]}%}%_> %{${reset_color}%}"
SPROMPT="%{${fg[yellow]}%}correct: %R -> %r [nyae]? %{${reset_color}%}"

# http://d.hatena.ne.jp/koyudoon/20111203/1322915316
# prompt as ({current_time}) {vi_mode} [{user_name}@{hostname}] {current_directory}\n% (# if root user)
# and show vi keybind mode at prompt
prompt_time="(%D{%Y/%m/%d %H:%M:%S})"
prompt_user="[%n@%{${fg[cyan]}%}%m%{${reset_color}%}]"
prompt_current_dir="%{${fg[blue]}%}%~"
prompt_self="%{${reset_color}%}%(!.#.%#) "

set_prompt() {
  local prompt_mode="INSERT"

  case $KEYMAP in
    vicmd)
      local prompt_mode="NORMAL"
    ;;
  esac

  PROMPT="${prompt_time} ${prompt_mode} ${prompt_user} ${prompt_current_dir}"$'\n'"${prompt_self}"
}
set_prompt

function zle-keymap-select {
  set_prompt
  zle reset-prompt
}
zle -N zle-keymap-select

# http://news.mynavi.jp/column/zsh/002/
# show terminal title as {user_name}@{hostname}:{current_directory}
case "${TERM}" in
kterm*|xterm*)
  precmd() {
    echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
  }

  # http://webtech-walker.com/archive/2008/12/15101251.html
  export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
  export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
  zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'
  ;;
esac

# http://memo.officebrook.net/20090316.html
bindkey -a 'q' push-line

# aliases
alias -g G="| grep"
alias -g V="| vim -R -"
alias -g FFTEST="TESTOPTS='--runner=failfast'"

alias g='git'
alias s='svn'

alias rm='rm -i'
alias ls='ls --color -a'
alias ll='ls -l'
alias vless='/usr/local/share/vim/vim73/macros/less.sh'
alias rak='rak --sort-files'
alias rak_app="rak -k 'db/|log/|public/|spec/|test/|tmp/|vendor/'"

alias cdb='cd ~/apps/${APP_NAME}/branch'
alias cdt='cd ~/apps/${APP_NAME}/trunk'
alias cdbd='cd ~/apps/${APP_NAME}/dummy_branch'
alias cdtd='cd ~/apps/${APP_NAME}/dummy_trunk'

alias 80='sudo ruby script/server webrick -p 80'
alias 443='sudo ruby script/webrick_ssl -p 443'
alias log='tail -f log/development.log'
alias log_test='tail -f log/test.log'

alias console='ruby script/console'
alias about='ruby script/about'
alias prepare='execute_with_echo "rake db:test:prepare"'
alias rake_units='      execute_with_echo "TEST_ENV_NUMBER=2 rake test:units $1"'
alias rake_functionals='execute_with_echo "TEST_ENV_NUMBER=3 rake test:functionals $1"'
alias rake_integration='execute_with_echo "TEST_ENV_NUMBER=4 rake test:integration $1"'
alias rake_js='         execute_with_echo "rake test:js"'
alias frake='execute_with_echo "rake FFTEST"'
alias frake_units='      execute_with_echo "rake_units FFTEST"'
alias frake_functionals='execute_with_echo "rake_functionals FFTEST"'
alias frake_integration='execute_with_echo "rake_integration FFTEST"'
alias mrake='execute_with_echo "migrate; execute_with_echo rake"'
alias rake_models='     execute_with_echo "TEST_ENV_NUMBER=2 rake spec:models"'
alias rake_controllers='execute_with_echo "TEST_ENV_NUMBER=3 rake spec:controllers"'
alias rake_helpers='    execute_with_echo "TEST_ENV_NUMBER=4 rake spec:helpers"'
alias ruby_multitest='ruby ${RUBYGEMS_PATH}rake-*/lib/rake/rake_test_loader.rb'

function execute_with_echo {
  cmd=$1;

  echo "----- ${cmd} ---------------";
  eval ${cmd};
}

function sdiff {
  execute_with_echo "svn diff --diff-cmd /usr/bin/diff -x '-U 10' V";
}

function slog {
  if (($# == 1)) then
    _limit=$1;
  else
    _limit="10";
  fi

  execute_with_echo "svn log -r HEAD:1 --limit ${_limit}";
}

function diffb {
  date=`date +"%y%m%d"`;

  if (($# == 1)) then
    rev=$1;
    filename="${date}_@${rev}_${APP_NAME}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/branches/ -c ${rev} > ${filename}";
  elif (($# == 3)) then
    branch=$1;
    rev_from=$2;
    rev_to=$3;
    filename="${date}_@${rev_from}-${rev_to}_${APP_NAME}_${branch}.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function difft {
  date=`date +"%y%m%d"`;

  if (($# == 1)) then
    rev=$1;
    filename="${date}_@${rev}_${APP_NAME}_trunk.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/trunk/ -c ${rev} > ${filename}";
  elif (($# == 2)) then
    rev_from=$1;
    rev_to=$2;
    filename="${date}_@${rev_from}-${rev_to}_${APP_NAME}_trunk.diff";
    cmd="svn diff --diff-cmd /usr/bin/diff -x '-U 10' ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to} > ${filename}";
  fi

  execute_with_echo ${cmd}
  execute_with_echo "vim -c ':e ++enc=utf-8' ${filename}";
}

function logb {
  branch=$1;
  rev_from=$2;
  rev_to=$3;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/branches/${branch}/ -r ${rev_from}:${rev_to}";
}

function logt {
  rev_from=$1;
  rev_to=$2;

  execute_with_echo "svn log ${TARGET_REPOSITORY_URL}/trunk/ -r ${rev_from}:${rev_to}";
}

function migrate {
  if (($# == 1)) then
    cmd="rake db:migrate VERSION=$1";
  else
    cmd="rake db:migrate";
  fi

  execute_with_echo ${cmd};
  execute_with_echo "rake db:test:clone_structure";
}

function tmux_setup_default {
  tmux new-session -d -s default
  tmux new-window -t default:2
  tmux new-window -t default:3
  tmux new-window -t default:4

  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux split-window -h -t default:1
  tmux select-layout -t default:1 even-horizontal

  tmux split-window -h -t default:2
  tmux select-layout -t default:2 main-vertical

  tmux select-window -t default:2
  tmux attach-session -t default
}

# http://d.hatena.ne.jp/itchyny/20130227/1361933011
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -dc $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

[ -f ~/.zsh/vim_visualmode.zsh ] && source ~/.zsh/vim_visualmode.zsh
[ -f ~/.zsh/my_aliases.zsh ] && source ~/.zsh/my_aliases.zsh
[ -f ~/.zsh/my_functions.zsh ] && source ~/.zsh/my_functions.zsh
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

