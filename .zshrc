# http://news.mynavi.jp/column/zsh/024/
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac

export VISUAL=vim
export EDITOR=vim

export GIT_EDITOR=vim
export LESS="--RAW-CONTROL-CHARS --LONG-PROMPT --no-init --quit-if-one-screen"

# http://dsas.blog.klab.org/archives/50808759.html
export GREP_COLOR='01;35'

export PROMPT_EOL_MARK=""

# History  {{{
HISTFILE=~/.zsh_histfile
HISTSIZE=100000
SAVEHIST=100000
HISTORY_IGNORE="exit|rm *-f*"

setopt hist_ignore_all_dups  # remove duplicated older command history

# http://news.mynavi.jp/column/zsh/004/
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# }}}

# Key Mappings: See also "History"  {{{
bindkey -v

# emacs like keybinds for INSERT mode
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

# http://memo.officebrook.net/20090316.html
bindkey -a "q" push-line
# }}}

# http://blog.blueblack.net/item_204
setopt long_list_jobs                        # 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt list_types                            # 補完候補一覧でファイルの種別をマーク表示
setopt auto_resume                           # サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_list                             # 補完候補を一覧表示
setopt hist_ignore_dups                      # 直前と同じコマンドをヒストリに追加しない
setopt auto_pushd                            # cd 時に自動で push
setopt pushd_ignore_dups                     # 同じディレクトリを pushd しない
setopt auto_menu                             # TAB で順に補完候補を切り替える
setopt extended_history                      # zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt hist_verify                           # ヒストリを呼び出してから実行する間に一旦編集
setopt numeric_glob_sort                     # ファイル名の展開で辞書順ではなく数値的にソート
setopt share_history                         # ヒストリを共有
zstyle ':completion:*:default' menu select=1 # 補完候補のカーソル選択を有効に
setopt auto_cd                               # ディレクトリ名だけで cd
setopt auto_param_keys                       # カッコの対応などを自動的に補完
setopt brace_ccl                             # {a-c} を a b c に展開する機能を使えるようにする
setopt NO_flow_control                       # Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt hist_ignore_space                     # コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt interactivecomments                   # コマンドラインでも # 以降をコメントと見なす
setopt hist_no_store                         # history (fc -l) コマンドをヒストリリストから取り除く。
setopt list_packed                           # 補完候補を詰めて表示

# prevent `zsh: no matches found: ....`
setopt nonomatch

# follow original file/directory via symbolic link
setopt chase_links

# prevent careless logout
setopt ignore_eof

# http://d.hatena.ne.jp/mollifier/20101227/p1
autoload -Uz zmv

autoload -U add-zsh-hook

source ~/.zsh/my_aliases.zsh
source ~/.zsh/my_functions.zsh
source ~/.zsh/timetrack.zsh
source ~/.zsh/tmux.zsh

# zdharma/zplugin  {{{
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
# }}}

zplugin ice silent wait; zplugin snippet ~/.zsh/direnv.zsh
zplugin ice silent wait; zplugin snippet ~/.zsh/goenv.zsh
zplugin ice silent wait; zplugin snippet ~/.zsh/nodenv.zsh
zplugin ice silent wait; zplugin snippet ~/.zsh/rbenv.zsh

source ~/.zsh/cd-bookmark.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/enhancd.zsh
source ~/.zsh/filter.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/syntax-highlighting.zsh

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

autoload -U compinit
compinit
