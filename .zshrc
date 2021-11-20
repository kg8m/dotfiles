export LANG=en_US.UTF-8

export VISUAL=vim
export EDITOR=vim

export GIT_EDITOR=vim
export LESS="--RAW-CONTROL-CHARS --LONG-PROMPT --no-init --quit-if-one-screen"
export LESSHISTFILE="${XDG_DATA_HOME:?}/less/lesshst"

mkdir -p "$(dirname "${LESSHISTFILE}")"

# http://dsas.blog.klab.org/archives/50808759.html
export GREP_COLOR='01;35'

# `PROMPT_EOL_MARK=""` hides "%" at the end of a partial line. Show the "%" because partial lines should be detected.
# export PROMPT_EOL_MARK=""

# History  {{{
export HISTFILE="${XDG_DATA_HOME:?}/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000
export HISTORY_IGNORE="rm -f*|git * -f*|*secret*|*SECRET*|*token*|*TOKEN*"

mkdir -p "$(dirname "${HISTFILE}")"

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

# Edit the command by Vim: Normal mode => e
autoload -z edit-command-line
zle -N edit-command-line
bindkey -a "e" edit-command-line
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
autoload -U zmv

autoload -U add-zsh-hook

mkdir -p "${KG8M_ZSH_CACHE_DIR:?}"

# Setup zinit
typeset -gAH ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zsh/zinit"

[ -d "${ZINIT[HOME_DIR]}/bin" ] || git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT[HOME_DIR]}/bin"
source "${ZINIT[HOME_DIR]}/bin/zinit.zsh"
autoload -U _zinit

# shellcheck disable=SC2034,SC2154
((${+_comps})) && _comps[zinit]=_zinit

source ~/.config/zsh/my-aliases.zsh
source ~/.config/zsh/my-functions.zsh

source ~/.config/zsh/binary-released-plugins.zsh
source ~/.config/zsh/cd-bookmark.zsh
source ~/.config/zsh/colors.zsh
source ~/.config/zsh/completion.zsh
source ~/.config/zsh/direnv.zsh
source ~/.config/zsh/enhancd.zsh
source ~/.config/zsh/filter.zsh
source ~/.config/zsh/git.zsh
source ~/.config/zsh/goenv.zsh
source ~/.config/zsh/history-search.zsh
source ~/.config/zsh/nodenv.zsh
source ~/.config/zsh/prompt.zsh
source ~/.config/zsh/rbenv.zsh
source ~/.config/zsh/rubocop.zsh
source ~/.config/zsh/syntax-highlighting.zsh
source ~/.config/zsh/timetrack.zsh
source ~/.config/zsh/tmux.zsh

source ~/.config/zsh/others.zsh

try_to_source ~/.config/zsh.local/.zshrc.local

zinit ice lucid nocd wait"!0c" compinit atload"echo"
zinit snippet /dev/null

# Notes
#
#   14.3 Parameter Expansion
#   https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
#
#     ${=spec}
#       Perform word splitting using the rules for SH_WORD_SPLIT during the evaluation of spec, but regardless of
#       whether the parameter appears in double quotes; if the '=' is doubled, turn it off. This forces parameter
#       expansions to be split into separate words before substitution, using IFS as a delimiter. This is done by
#       default in most other shells.
#
#       Note that splitting is applied to word in the assignment forms of spec before the assignment to name is
#       performed. This affects the result of array assignments with the A flag.
#
#   14.3.1 Parameter Expansion Flags
#   https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
#
#     @
#       In double quotes, array elements are put into separate words. E.g., '"${(@)foo}"' is equivalent to
#       '"${foo[@]}"' and '"${(@)foo[1,2]}"' is the same as '"$foo[1]" "$foo[2]"'. This is distinct from field
#       splitting by the f, s or z flags, which still applies within each array element.
#
#     f
#       Split the result of the expansion at newlines. This is a shorthand for 'ps:\n:'.
#
#     p
#       Recognize the same escape sequences as the print builtin in string arguments to any of the flags described
#       below that follow this argument.
#
#       Alternatively, with this option string arguments may be in the form $var in which case the value of the
#       variable is substituted. Note this form is strict; the string argument does not undergo general parameter
#       expansion.
#
#       For example,
#
#         sep=:
#         val=a:b:c
#         print ${(ps.$sep.)val}
#
#       splits the variable on a :.
#
#     j:string:
#       Join the words of arrays together using string as a separator. Note that this occurs before field splitting by
#       the s:string: flag or the SH_WORD_SPLIT option.
#
#     r:expr::string1::string2:
#       As l, but pad the words on the right and insert string2 immediately to the right of the string to be padded.
#
#       Left and right padding may be used together. In this case the strategy is to apply left padding to the first
#       half width of each of the resulting words, and right padding to the second half. If the string to be padded has
#       odd width the extra padding is applied on the left.
#
#     s:string:
#       Force field splitting at the separator string. Note that a string of two or more characters means that all of
#       them must match in sequence; this differs from the treatment of two or more characters in the IFS parameter. See
#       also the = flag and the SH_WORD_SPLIT option. An empty string may also be given in which case every character
#       will be a separate element.
#
#       For historical reasons, the usual behaviour that empty array elements are retained inside double quotes is
#       disabled for arrays generated by splitting; hence the following:
#
#         line="one::three"
#         print -l "${(s.:.)line}"
#
#       produces two lines of output for one and three and elides the empty field. To override this behaviour, supply
#       the '(@)' flag as well, i.e. "${(@s.:.)line}".
#
#     M
#       Include the matched portion in the result.
#
#     R
#       Include the unmatched portion in the result (the Rest).
#
#   15.2.3 Subscript Flags
#   https://zsh.sourceforge.io/Doc/Release/Parameters.html#Subscript-Flags
#
#     r
#       Reverse subscripting: if this flag is given, the exp is taken as a pattern and the result is the first matching
#       array element, substring or word (if the parameter is an array, if it is a scalar, or if it is a scalar and the
#       'w' flag is given, respectively). The subscript used is the number of the matching element, so that pairs of
#       subscripts such as '$foo[(r)??,3]' and '$foo[(r)??,(r)f*]' are possible if the parameter is not an associative
#       array. If the parameter is an associative array, only the value part of each pair is compared to the pattern,
#       and the result is that value.
#
#       If a search through an ordinary array failed, the search sets the subscript to one past the end of the array,
#       and hence ${array[(r)pattern]} will substitute the empty string. Thus the success of a search can be tested by
#       using the (i) flag, for example (assuming the option KSH_ARRAYS is not in effect):
#
#         [[ ${array[(i)pattern]} -le ${#array} ]]
#
#       If KSH_ARRAYS is in effect, the -le should be replaced by -lt.
#
#     i
#       Like 'r', but gives the index of the match instead; this may not be combined with a second argument. On the left
#       side of an assignment, behaves like 'r'. For associative arrays, the key part of each pair is compared to the
#       pattern, and the first matching key found is the result. On failure substitutes the length of the array plus
#       one, as discussed under the description of 'r', or the empty string for an associative array.
#
#     I
#       Like 'i', but gives the index of the last match, or all possible matching keys in an associative array. On
#       failure substitutes 0, or the empty string for an associative array. This flag is best when testing for values
#       or keys that do not exist.
