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
export HISTFILE=~/.zsh_histfile
export HISTSIZE=100000
export SAVEHIST=100000
export HISTORY_IGNORE="exit|rm *-f*|*secret*|*SECRET*|*token*|*TOKEN*"

# https://mollifier.hatenablog.com/entry/20090728/p1
zshaddhistory() {
  local line=${1%%$'\n'}

  [[ ${#line} -ge 5 ]]
}

setopt extended_history      # Record each command's timestamp and the duration
setopt hist_ignore_all_dups  # Remove duplicated older commands from history
setopt hist_ignore_space     # Remove history when the first character is a space
setopt hist_no_store         # Ignore the `history` (`fc -l`) command
setopt hist_verify           # Expand a command from history, but not execute it directly
setopt share_history         # Share history
# }}}

# Key Mappings  {{{
bindkey -v

# emacs like keybinds for INSERT mode
bindkey "^F" forward-char
bindkey "^B" backward-char
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

# http://memo.officebrook.net/20090316.html
bindkey -a "q" push-line
# }}}

# http://blog.blueblack.net/item_204
setopt long_list_jobs       # 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt list_types           # 補完候補一覧でファイルの種別をマーク表示
setopt auto_resume          # サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_list            # 補完候補を一覧表示
setopt auto_pushd           # cd 時に自動で push
setopt pushd_ignore_dups    # 同じディレクトリを pushd しない
setopt auto_menu            # TAB で順に補完候補を切り替える
setopt numeric_glob_sort    # ファイル名の展開で辞書順ではなく数値的にソート
setopt auto_cd              # ディレクトリ名だけで cd
setopt auto_param_keys      # カッコの対応などを自動的に補完
setopt brace_ccl            # {a-c} を a b c に展開する機能を使えるようにする
setopt NO_flow_control      # Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt interactivecomments  # コマンドラインでも # 以降をコメントと見なす
setopt list_packed          # 補完候補を詰めて表示

# Prevent `zsh: no matches found: ....`
setopt nonomatch

# Follow original file/directory via symbolic link
setopt chase_links

# Prevent careless logout
setopt ignore_eof

# http://d.hatena.ne.jp/mollifier/20101227/p1
autoload -Uz zmv

autoload -U add-zsh-hook

mkdir -p "${KGYM_ZSH_CACHE_DIR:-}"

# zdharma/zinit  {{{
[ -d ~/.zinit/bin ] || git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
source ~/.zinit/bin/zinit.zsh
autoload -Uz _zinit

# shellcheck disable=SC2034,SC2154
((${+_comps})) && _comps[zinit]=_zinit
# }}}

source ~/.zsh/cd-bookmark.zsh
source ~/.zsh/colors.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/direnv.zsh
source ~/.zsh/enhancd.zsh
source ~/.zsh/filter.zsh
source ~/.zsh/git.zsh
source ~/.zsh/goenv.zsh
source ~/.zsh/history-search.zsh
source ~/.zsh/my_aliases.zsh
source ~/.zsh/my_functions.zsh
source ~/.zsh/nodenv.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/rbenv.zsh
source ~/.zsh/rubocop.zsh
source ~/.zsh/syntax-highlighting.zsh
source ~/.zsh/timetrack.zsh
source ~/.zsh/tmux.zsh

try_to_source ~/.zshrc.local

zinit ice lucid nocd wait"!0c" compinit atload"echo"
zinit snippet /dev/null
