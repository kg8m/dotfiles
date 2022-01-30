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
#     ${name-word}
#     ${name:-word}
#       If `name` is set, or in the second form is non-null, then substitute its value; otherwise substitute `word`. In
#       the second form `name` may be omitted, in which case `word` is always substituted.
#
#     ${name=word}
#     ${name:=word}
#     ${name::=word}
#       In the first form, if `name` is unset then set it to `word`; in the second form, if `name` is unset or null then
#       set it to `word`; and in the third form, unconditionally set `name` to `word`. In all forms, the value of the
#       parameter is then substituted.
#
#     ${name?word}
#     ${name:?word}
#       In the first form, if `name` is set, or in the second form if `name` is both set and non-null, then substitute
#       its value; otherwise, print `word` and exit from the shell. Interactive shells instead return to the prompt. If
#       `word` is omitted, then a standard message is printed.
#
#     ${name#pattern}
#     ${name##pattern}
#       If the `pattern` matches the beginning of the value of `name`, then substitute the value of `name` with the
#       matched portion deleted; otherwise, just substitute the value of `name`. In the first form, the smallest
#       matching `pattern` is preferred; in the second form, the largest matching `pattern` is preferred.
#
#     ${name%pattern}
#     ${name%%pattern}
#       If the `pattern` matches the end of the value of `name`, then substitute the value of `name` with the matched
#       portion deleted; otherwise, just substitute the value of `name`. In the first form, the smallest matching
#       `pattern` is preferred; in the second form, the largest matching `pattern` is preferred.
#
#     ${name:#pattern}
#       If the `pattern` matches the value of `name`, then substitute the empty string; otherwise, just substitute the
#       value of `name`. If `name` is an array the matching array elements are removed (use the `(M)` flag to remove
#       the non-matched elements).
#
#     ${name:|arrayname}
#       If `arrayname` is the name (N.B., not contents) of an array variable, then any elements contained in `arrayname`
#       are removed from the substitution of `name`. If the substitution is scalar, either because `name` is a scalar
#       variable or the expression is quoted, the elements of `arrayname` are instead tested against the entire
#       expression.
#
#     ${name:*arrayname}
#       Similar to the preceding substitution, but in the opposite sense, so that entries present in both the original
#       substitution and as elements of `arrayname` are retained and others removed.
#
#     ${name:^arrayname}
#     ${name:^^arrayname}
#       Zips two arrays, such that the output array is twice as long as the shortest (longest for `:^^`) of `name` and
#       `arrayname`, with the elements alternatingly being picked from them. For `:^`, if one of the input arrays is
#       longer, the output will stop when the end of the shorter array is reached. Thus,
#
#         a=(1 2 3 4); b=(a b); print ${a:^b}
#
#       will output `1 a 2 b`. For `:^^`, then the input is repeated until all of the longer array has been used up and
#       the above will output `1 a 2 b 3 a 4 b`.
#
#       Either or both inputs may be a scalar, they will be treated as an array of length 1 with the scalar as the only
#       element. If either array is empty, the other array is output with no extra elements inserted.
#
#       Currently the following code will output `a b` and `1` as two separate elements, which can be unexpected. The
#       second print provides a workaround which should continue to work if this is changed.
#
#         a=(a b); b=(1 2); print -l "${a:^b}"; print -l "${${a:^b}}"
#
#     ${name:offset}
#     ${name:offset:length}
#       This syntax gives effects similar to parameter subscripting in the form `$name[start,end]`, but is compatible
#       with other shells; note that both `offset` and `length` are interpreted differently from the components of a
#       subscript.
#
#       If `offset` is non-negative, then if the variable `name` is a scalar substitute the contents starting `offset`
#       characters from the first character of the string, and if `name` is an array substitute elements starting
#       `offset` elements from the first element. If `length` is given, substitute that many characters or elements,
#       otherwise the entire rest of the scalar or array.
#
#       A positive `offset` is always treated as the `offset` of a character or element in `name` from the first
#       character or element of the array (this is different from native zsh subscript notation). Hence 0 refers to the
#       first character or element regardless of the setting of the option `KSH_ARRAYS`.
#
#       A negative `offset` counts backwards from the end of the scalar or array, so that -1 corresponds to the last
#       character or element, and so on.
#
#       When positive, `length` counts from the `offset` position toward the end of the scalar or array. When negative,
#       `length` counts back from the end. If this results in a position smaller than `offset`, a diagnostic is printed
#       and nothing is substituted.
#
#       The option `MULTIBYTE` is obeyed, i.e. the offset and length count multibyte characters where appropriate.
#
#       `offset` and `length` undergo the same set of shell substitutions as for scalar assignment; in addition, they
#       are then subject to arithmetic evaluation. Hence, for example
#
#         print ${foo:3}
#         print ${foo: 1 + 2}
#         print ${foo:$(( 1 + 2))}
#         print ${foo:$(echo 1 + 2)}
#
#       all have the same effect, extracting the string starting at the fourth character of `$foo` if the substitution
#       would otherwise return a scalar, or the array starting at the fourth element if `$foo` would return an array.
#       Note that with the option `KSH_ARRAYS $foo` always returns a scalar (regardless of the use of the offset syntax)
#       and a form such as `${foo[*]:3}` is required to extract elements of an array named `foo`.
#
#       If `offset` is negative, the `-` may not appear immediately after the `:` as this indicates the `${name:-word}`
#       form of substitution. Instead, a space may be inserted before the `-`. Furthermore, neither `offset` nor
#       `length` may begin with an alphabetic character or `&` as these are used to indicate history-style modifiers. To
#       substitute a value from a variable, the recommended approach is to precede it with a $ as this signifies the
#       intention (parameter substitution can easily be rendered unreadable); however, as arithmetic substitution is
#       performed, the expression `${var: offs}` does work, retrieving the offset from `$offs`.
#
#       For further compatibility with other shells there is a special case for array offset 0. This usually accesses
#       the first element of the array. However, if the substitution refers to the positional parameter array, e.g. `$@`
#       or `$*`, then offset 0 instead refers to `$0`, offset 1 refers to `$1`, and so on. In other words, the
#       positional parameter array is effectively extended by prepending `$0`. Hence `${*:0:1}` substitutes `$0` and
#       `${*:1:1}` substitutes `$1`.
#
#         ${name/pattern/repl}
#         ${name//pattern/repl}
#         ${name:/pattern/repl}
#
#       Replace the longest possible match of `pattern` in the expansion of parameter `name` by string `repl`. The first
#       form replaces just the first occurrence, the second form all occurrences, and the third form replaces only if
#       `pattern` matches the entire string. Both `pattern` and `repl` are subject to double-quoted substitution, so
#       that expressions like `${name/$opat/$npat}` will work, but obey the usual rule that pattern characters in
#       `$opat` are not treated specially unless either the option `GLOB_SUBST` is set, or $opat is instead substituted
#       as `${~opat}`.
#
#       The `pattern` may begin with a `#`, in which case the `pattern` must match at the start of the string, or `%`,
#       in which case it must match at the end of the string, or `#%` in which case the `pattern` must match the entire
#       string. The `repl` may be an empty string, in which case the final `/` may also be omitted. To quote the final
#       `/` in other cases it should be preceded by a single backslash; this is not necessary if the `/` occurs inside a
#       substituted parameter. Note also that the `#`, `%` and `#%` are not active if they occur inside a substituted
#       parameter, even at the start.
#
#       If, after quoting rules apply, `${name}` expands to an array, the replacements act on each element individually.
#       Note also the effect of the I and S parameter expansion flags below; however, the flags `M`, `R`, `B`, `E` and
#       `N` are not useful.
#
#       For example,
#
#         foo="twinkle twinkle little star" sub="t*e" rep="spy"
#         print ${foo//${~sub}/$rep}
#         print ${(S)foo//${~sub}/$rep}
#
#       Here, the `~` ensures that the text of `$sub` is treated as a pattern rather than a plain string. In the first
#       case, the longest match for `t*e` is substituted and the result is `spy star`, while in the second case, the
#       shortest matches are taken and the result is `spy spy lispy star`.
#
#     ${=spec}
#       Perform word splitting using the rules for `SH_WORD_SPLIT` during the evaluation of `spec`, but regardless of
#       whether the parameter appears in double quotes; if the `=` is doubled, turn it off. This forces parameter
#       expansions to be split into separate words before substitution, using `IFS` as a delimiter. This is done by
#       default in most other shells.
#
#       Note that splitting is applied to `word` in the assignment forms of `spec` before the assignment to `name` is
#       performed. This affects the result of array assignments with the `A` flag.
#
#   14.3.1 Parameter Expansion Flags
#   https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
#
#     @
#       In double quotes, array elements are put into separate words. E.g., `"${(@)foo}"` is equivalent to
#       `"${foo[@]}"` and `"${(@)foo[1,2]}"` is the same as `"$foo[1]" "$foo[2]"`. This is distinct from field
#       splitting by the `f`, `s` or `z` flags, which still applies within each array element.
#
#     f
#       Split the result of the expansion at newlines. This is a shorthand for `ps:\n:`.
#
#     p
#       Recognize the same escape sequences as the print builtin in string arguments to any of the flags described
#       below that follow this argument.
#
#       Alternatively, with this option string arguments may be in the form `$var` in which case the value of the
#       variable is substituted. Note this form is strict; the string argument does not undergo general parameter
#       expansion.
#
#       For example,
#
#         sep=:
#         val=a:b:c
#         print ${(ps.$sep.)val}
#
#       splits the variable on a `:`.
#
#     j:string:
#       Join the words of arrays together using `string` as a separator. Note that this occurs before field splitting by
#       the `s:string:` flag or the `SH_WORD_SPLIT` option.
#
#     l:expr::string1::string2:
#       Pad the resulting words on the left. Each word will be truncated if required and placed in a field `expr`
#       characters wide.
#
#       The arguments `:string1:` and `:string2:` are optional; neither, the first, or both may be given. Note that the
#       same pairs of delimiters must be used for each of the three arguments. The space to the left will be filled with
#       `string1` (concatenated as often as needed) or spaces if `string1` is not given. If both `string1` and `string2`
#       are given, `string2` is inserted once directly to the left of each word, truncated if necessary, before
#       `string1` is used to produce any remaining padding.
#
#       If either of `string1` or `string2` is present but empty, i.e. there are two delimiters together at that point,
#       the first character of `$IFS` is used instead.
#
#       If the `MULTIBYTE` option is in effect, the flag `m` may also be given, in which case widths will be used for
#       the calculation of padding; otherwise individual multibyte characters are treated as occupying one unit of
#       width.
#
#       If the `MULTIBYTE` option is not in effect, each byte in the string is treated as occupying one unit of width.
#
#       Control characters are always assumed to be one unit wide; this allows the mechanism to be used for generating
#       repetitions of control characters.
#
#     r:expr::string1::string2:
#       As `l`, but pad the words on the right and insert `string2` immediately to the right of the string to be padded.
#
#       Left and right padding may be used together. In this case the strategy is to apply left padding to the first
#       half width of each of the resulting words, and right padding to the second half. If the string to be padded has
#       odd width the extra padding is applied on the left.
#
#     s:string:
#       Force field splitting at the separator `string`. Note that a `string` of two or more characters means that all
#       of them must match in sequence; this differs from the treatment of two or more characters in the `IFS`
#       parameter. See also the `=` flag and the `SH_WORD_SPLIT` option. An empty string may also be given in which case
#       every character will be a separate element.
#
#       For historical reasons, the usual behaviour that empty array elements are retained inside double quotes is
#       disabled for arrays generated by splitting; hence the following:
#
#         line="one::three"
#         print -l "${(s.:.)line}"
#
#       produces two lines of output for one and three and elides the empty field. To override this behaviour, supply
#       the `(@)` flag as well, i.e. `${(@s.:.)line}`.
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
#       `w` flag is given, respectively). The subscript used is the number of the matching element, so that pairs of
#       subscripts such as `$foo[(r)??,3]` and `$foo[(r)??,(r)f*]` are possible if the parameter is not an associative
#       array. If the parameter is an associative array, only the value part of each pair is compared to the pattern,
#       and the result is that value.
#
#       If a search through an ordinary array failed, the search sets the subscript to one past the end of the array,
#       and hence `${array[(r)pattern]}` will substitute the empty string. Thus the success of a search can be tested by
#       using the `(i)` flag, for example (assuming the option `KSH_ARRAYS` is not in effect):
#
#         [[ ${array[(i)pattern]} -le ${#array} ]]
#
#       If `KSH_ARRAYS` is in effect, the `-le` should be replaced by `-lt`.
#
#     i
#       Like `r`, but gives the index of the match instead; this may not be combined with a second argument. On the left
#       side of an assignment, behaves like `r`. For associative arrays, the key part of each pair is compared to the
#       pattern, and the first matching key found is the result. On failure substitutes the length of the array plus
#       one, as discussed under the description of `r`, or the empty string for an associative array.
#
#     I
#       Like `i`, but gives the index of the last match, or all possible matching keys in an associative array. On
#       failure substitutes 0, or the empty string for an associative array. This flag is best when testing for values
#       or keys that do not exist.
