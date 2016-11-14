# http://news.mynavi.jp/column/zsh/024/
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

export VISUAL=vim
export EDITOR=vim

if [ -e ~/svn_editor.sh ]; then
  export SVN_EDITOR="sh ~/svn_editor.sh"
else
  export SVN_EDITOR=vim
fi

export GIT_EDITOR=vim
export LESS="--RAW-CONTROL-CHARS --LONG-PROMPT --no-init --quit-if-one-screen"

export GOROOT=$HOME/.go
export GOBIN=$GOROOT/bin
export GOPATH=$HOME/go

# http://dsas.blog.klab.org/archives/50808759.html
export GREP_COLOR='01;35'
# export GREP_OPTIONS='--color=always'

HISTFILE=~/.zsh_histfile
HISTSIZE=100000
SAVEHIST=100000

bindkey -v

# emacs like keybinds for INSERT mode
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

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
setopt brace_ccl                             # {a-c} を a b c に展開する機能を使えるようにする
setopt NO_flow_control                       # Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt hist_ignore_space                     # コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt interactivecomments                   # コマンドラインでも # 以降をコメントと見なす
setopt mark_dirs                             # ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt hist_no_store                         # history (fc -l) コマンドをヒストリリストから取り除く。
setopt list_packed                           # 補完候補を詰めて表示
setopt noautoremoveslash                     # 最後のスラッシュを自動的に削除しない

# prevent `zsh: no matches found: ....`
setopt nonomatch

setopt hist_ignore_all_dups  # remove duplicated older command history

# follow original file/directory via symbolic link
setopt chase_links

# prevent careless logout
setopt ignore_eof

# completion candidates include aliases
# incompatible with cd-bookmark
# setopt complete_aliases

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

# https://github.com/yonchu/zsh-vcs-prompt
if [ -f ~/.zsh/zsh-vcs-prompt/zshrc.sh ]; then
  ZSH_VCS_PROMPT_ENABLE_CACHING='true'
  source ~/.zsh/zsh-vcs-prompt/zshrc.sh
else
  function vcs_super_info {}
fi

# http://d.hatena.ne.jp/koyudoon/20111203/1322915316
# prompt as ({current_time}) [{vi_mode}] {user_name}@{hostname} : {current_directory_path}\n% (# if root user)
prompt_time=$'\e[48;05;024m'"(%D{%Y/%m/%d(%a) %H:%M:%S})"$'\e[48;05;000m'
prompt_user=$'\e[38;05;009m'"%n@%m"
prompt_current_dir=$'\e[38;05;030m'"%~"$'%{${reset_color}%}'
prompt_vcs='$(vcs_super_info)$(git_user_info)'
prompt_self=$'%{${reset_color}%}'"%(!.#.%#) "

git_user_info() {
  if [ "$(git status 2> /dev/null)" ]; then
    echo " - `git config user.name` (`git config user.email`)"
  fi
}

set_prompt() {
  local prompt_mode="INSERT"

  case $KEYMAP in
    vicmd)
      local prompt_mode="NORMAL"
    ;;
  esac

  PROMPT="${prompt_time} "$'\e[38;05;245m'"[${prompt_mode}] ${prompt_user}"$'\e[38;05;245m'" : ${prompt_current_dir} ${prompt_vcs}"$'\n'"${prompt_self}"
}
set_prompt

function zle-keymap-select {
  set_prompt
  zle reset-prompt
}
zle -N zle-keymap-select

# zsh-vcs-prompt
ZSH_VCS_PROMPT_AHEAD_SIGIL='^'
ZSH_VCS_PROMPT_BEHIND_SIGIL='v'
ZSH_VCS_PROMPT_STAGED_SIGIL='+'
ZSH_VCS_PROMPT_CONFLICTS_SIGIL='C'
ZSH_VCS_PROMPT_UNSTAGED_SIGIL='!'
ZSH_VCS_PROMPT_UNTRACKED_SIGIL='?'
ZSH_VCS_PROMPT_STASHED_SIGIL='!?'
ZSH_VCS_PROMPT_CLEAN_SIGIL='#'

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

[ -f ~/.zsh/timetrack.zsh      ] && source ~/.zsh/timetrack.zsh
[ -f ~/.zsh/cd-bookmark.zsh    ] && source ~/.zsh/cd-bookmark.zsh
[ -f ~/.zsh/enhancd/enhancd.sh ] && source ~/.zsh/enhancd/enhancd.sh
[ -f ~/.zsh/my_env.zsh         ] && source ~/.zsh/my_env.zsh
[ -f ~/.zsh/my_aliases.zsh     ] && source ~/.zsh/my_aliases.zsh
[ -f ~/.zsh/my_functions.zsh   ] && source ~/.zsh/my_functions.zsh
[ -f ~/.zsh/peco.zsh           ] && source ~/.zsh/peco.zsh
[ -f ~/.zsh/direnv.zsh         ] && source ~/.zsh/direnv.zsh
[ -f ~/.zsh/rbenv.zsh          ] && source ~/.zsh/rbenv.zsh
[ -f ~/.zsh/nodenv.zsh         ] && source ~/.zsh/nodenv.zsh

autoload -U compinit
compinit

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

