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

# http://mint.hateblo.jp/entry/2012/12/17/175553
autoload -U add-zsh-hook
set_tmux_window_name() {
  if [ $TMUX ]; then
    local _pwd=${PWD:t}
    tmux rename-window "$_pwd"
  fi
}
set_tmux_window_name
add-zsh-hook precmd set_tmux_window_name

# http://memo.officebrook.net/20090316.html
bindkey -a 'q' push-line

[ -f ~/.zsh/vim_visualmode.zsh ] && source ~/.zsh/vim_visualmode.zsh
[ -f ~/.zsh/my_aliases.zsh ] && source ~/.zsh/my_aliases.zsh
[ -f ~/.zsh/my_functions.zsh ] && source ~/.zsh/my_functions.zsh
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

