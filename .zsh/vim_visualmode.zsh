# http://zshscreenvimvimpwget.blog27.fc2.com/blog-entry-3.html
# make keybind like vim
#vim-visual-modeを実装
bindkey -a 'v' vi-v
zle -N vi-v
function vi-v() {
  VI_VIS_MODE=0
  bindkey -a 'v' vi-vis-reset
  bindkey -a '' vi-c-v
  bindkey -a 'V' vi-V
  MARK=$CURSOR
  zle vi-vis-mode
}
#
bindkey -a '' vi-c-v
zle -N vi-c-v
function vi-c-v() {
  VI_VIS_MODE=1
  bindkey -a 'v' vi-v
  bindkey -a '' vi-vis-reset
  bindkey -a 'V' vi-V
  MARK=$CURSOR
  zle vi-vis-mode
}
#
bindkey -a 'V' vi-V
zle -N vi-V
function vi-V() {
  VI_VIS_MODE=2
  bindkey -a 'v' vi-v
  bindkey -a '' vi-c-v
  bindkey -a 'V' vi-vis-reset
  CURSOR_V_START=$CURSOR
  zle vi-end-of-line
  MARK=$(($CURSOR - 1))
  zle vi-digit-or-beginning-of-line
  zle vi-vis-mode
}
#
##########################################################
#
zle -N vi-vis-mode
function vi-vis-mode() {
  zle exchange-point-and-mark
  VI_VIS_CURSOR_MARK=1
#移動系コマンド
  bindkey -a 'f' vi-vis-find
  bindkey -a 'F' vi-vis-Find
  bindkey -a 't' vi-vis-tskip
  bindkey -a 'T' vi-vis-Tskip
  bindkey -a ';' vi-vis-repeatfind
  bindkey -a ',' vi-vis-repeatfindrev
  bindkey -a 'w' vi-vis-word
  bindkey -a 'W' vi-vis-Word
  bindkey -a 'e' vi-vis-end
  bindkey -a 'E' vi-vis-End
  bindkey -a 'b' vi-vis-back
  bindkey -a 'B' vi-vis-Back
  bindkey -a 'h' vi-vis-hidari
  bindkey -a 'l' vi-vis-leftdenai
  bindkey -a '%' vi-vis-percent
  bindkey -a '^' vi-vis-hat
  bindkey -a '0' vi-vis-zero
  bindkey -a '$' vi-vis-doller
#削除、コピーetc
  bindkey -a 'd' vi-vis-delete
  bindkey -a 'D' vi-vis-Delete
  bindkey -a 'x' vi-vis-delete
  bindkey -a 'X' vi-vis-Delete
  bindkey -a 'y' vi-vis-yank
  bindkey -a 'Y' vi-vis-Yank
  bindkey -a 'c' vi-vis-change
  bindkey -a 'C' vi-vis-Change
  bindkey -a 'r' vi-vis-change
  bindkey -a 'R' vi-vis-Change
  bindkey -a 'p' vi-vis-paste
  bindkey -a 'P' vi-vis-Paste
  bindkey -a 'o' vi-vis-open
  bindkey -a 'O' vi-vis-open
#インサートへ移行
  bindkey -a 'a' vi-vis-add
  bindkey -a 'A' vi-vis-Add
  bindkey -a 'i' vi-vis-insert
  bindkey -a 'I' vi-vis-Insert
#その他
  bindkey -a 'u' vi-vis-undo
  bindkey -a '.' vi-vis-repeat
  bindkey -a '' vi-vis-reset
  bindkey -a 's' vi-vis-reset
  bindkey -a 'S' vi-vis-reset
}
#
zle -N vi-vis-key-reset
function vi-vis-key-reset() {
  bindkey -M vicmd 'f' vi-find-next-char
  bindkey -M vicmd 'F' vi-find-prev-char
  bindkey -M vicmd 't' vi-find-next-char-skip
  bindkey -M vicmd 'T' vi-find-prev-char-skip
  bindkey -M vicmd ';' vi-repeat-find
  bindkey -M vicmd ',' vi-rev-repeat-find
  bindkey -M vicmd 'w' vi-forward-word
  bindkey -M vicmd 'W' vi-forward-blank-word
  bindkey -M vicmd 'e' vi-forward-word-end
  bindkey -M vicmd 'E' vi-forward-blank-word-end
  bindkey -M vicmd 'b' vi-backward-word
  bindkey -M vicmd 'B' vi-backward-blank-word
  bindkey -M vicmd 'h' vi-h-moto
  bindkey -M vicmd 'l' vi-l-moto
  bindkey -M vicmd '%' vi-match-bracket
  bindkey -M vicmd '^' vi-first-non-blank
  bindkey -M vicmd '0' vi-digit-or-beginning-of-line
  bindkey -M vicmd '$' vi-end-of-line
  bindkey -M vicmd 'd' vi-delete
  bindkey -M vicmd 'D' vi-kill-eol
  bindkey -M vicmd 'x' vi-delete-char  
  bindkey -M vicmd 'X' vi-backward-delete-char
  bindkey -M vicmd 'y' vi-yank
  bindkey -M vicmd 'Y' vi-yank-whole-line
  bindkey -M vicmd 'c' vi-change
  bindkey -M vicmd 'C' vi-change-eol
  bindkey -M vicmd 'r' vi-replace-chars
  bindkey -M vicmd 'R' vi-replace
  bindkey -M vicmd 'p' vi-put-after
  bindkey -M vicmd 'P' vi-put-before
  bindkey -M vicmd 'o' vi-open-line-below
  bindkey -M vicmd 'O' vi-open-line-above
  bindkey -M vicmd 'a' vi-add-next
  bindkey -M vicmd 'A' vi-add-eol
  bindkey -M vicmd 'i' vi-insert
  bindkey -M vicmd 'I' vi-insert-bol
  bindkey -M vicmd 'u' vi-undo-change
  bindkey -M vicmd '.' vi-repeat-change
  bindkey -M vicmd 'v' vi-v
  bindkey -M vicmd '' vi-c-v
  bindkey -M vicmd 'V' vi-V
  bindkey -M vicmd 's' vi-substitute
  bindkey -M vicmd 'S' vi-change-whole-line 
}
#
##########################################################
#
zle -N vi-vis-cursor-shori_before
function vi-vis-cursor-shori_before() {
  if [ $MARK -lt $(( $CURSOR + 1 )) ] ;then
    VI_VIS_CURSOR_MARK=1
  elif [ $MARK -eq $(( $CURSOR + 1 )) ] ;then 
    VI_VIS_CURSOR_MARK=0
  else
    VI_VIS_CURSOR_MARK=-1
  fi
}
#
zle -N vi-vis-cursor-shori_after
function vi-vis-cursor-shori_after() {
  if [ $MARK -lt $(( $CURSOR + 1 )) ] ;then
    if [ ${VI_VIS_CURSOR_MARK} -eq 1 ] ;then
      MARK=$MARK
      CURSOR=$CURSOR
      VI_VIS_CURSOR_MARK=1
    elif [ ${VI_VIS_CURSOR_MARK} -eq 0 ] ;then
# これは起こらないはず      
      MARK=$MARK
      CURSOR=$CURSOR
      VI_VIS_CURSOR_MARK=1
    else
      MARK=$(( $MARK - 1 ))
      CURSOR=$CURSOR
      VI_VIS_CURSOR_MARK=1
    fi
  elif [ $MARK -eq $(( $CURSOR + 1 )) ] ;then 
    if [ ${VI_VIS_CURSOR_MARK} -eq 1 ] ;then
      MARK=$(( $MARK + 1 ))
      CURSOR=$(( $CURSOR - 1 ))
      VI_VIS_CURSOR_MARK=-1
    elif [ ${VI_VIS_CURSOR_MARK} -eq 0 ] ;then
# これは起こらないはず      
      MARK=$MARK
      CURSOR=$CURSOR
    else
      MARK=$(( $MARK - 1 ))
      CURSOR=$CURSOR
      VI_VIS_CURSOR_MARK=+1
    fi
  else
    if [ ${VI_VIS_CURSOR_MARK} -eq 1 ] ;then
      MARK=$(( $MARK + 1 ))
      CURSOR=$(( $CURSOR - 1 ))
      VI_VIS_CURSOR_MARK=-1
    elif [ ${VI_VIS_CURSOR_MARK} -eq 0 ] ;then
#これは起こらないはず
      MARK=$(( $MARK + 1 ))
      CURSOR=$(( $CURSOR - 1 ))
      VI_VIS_CURSOR_MARK=-1
    else
      MARK=$MARK
      CURSOR=$(( $CURSOR - 1 ))
      VI_VIS_CURSOR_MARK=-1
    fi
  fi
}
#
zle -N vi-h-moto
function vi-h-moto() {
  CURSOR=$(( $CURSOR - 1 ))
}
#
zle -N vi-l-moto
function vi-l-moto() {
  CURSOR=$(( $CURSOR + 1 ))
}
#
##########################################################
#
zle -N vi-vis-find
function vi-vis-find() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-find-next-char
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-Find
function vi-vis-Find() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-find-prev-char
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-tskip
function vi-vis-tskip() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-find-next-char-skip
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-Tskip
function vi-vis-Tskip() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-find-prev-char-skip
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-repeatfind
function vi-vis-repeatfind() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-repeat-find
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-repeatfindrev
function vi-vis-repeatfindrev() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-rev-repeat-find
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-word
function vi-vis-word() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-forward-word
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-Word
function vi-vis-Word() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-forward-blank-word
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-end
function vi-vis-end() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-forward-word-end
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-End
function vi-vis-End() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-forward-blank-word-end
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-back
function vi-vis-back() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-backward-word
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-Back
function vi-vis-Back() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-backward-blank-word
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-hidari
function vi-vis-hidari() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  CURSOR=$(( $CURSOR - 1 ))
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-leftdenai
function vi-vis-leftdenai() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  CURSOR=$(( $CURSOR + 1 ))
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-percent
function vi-vis-percent() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-match-bracket
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-hat
function vi-vis-hat() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-first-non-blank
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-zero
function vi-vis-zero() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-digit-or-beginning-of-line
  zle vi-vis-cursor-shori_after
}
#
zle -N vi-vis-doller
function vi-vis-doller() {
  if [ ${VI_VIS_CURSOR_MARK} -eq -1 ] ;then
    CURSOR=$(( $CURSOR + 1 ))
  fi
  zle vi-vis-cursor-shori_before
  zle vi-end-of-line
  zle vi-vis-cursor-shori_after
}
#
##########################################################
#
zle -N vi-vis-delete
function vi-vis-delete() {
  zle vi-vis-key-reset
  CURSOR=$(($CURSOR + 1))
  zle kill-region
}
#
zle -N vi-vis-Delete
function vi-vis-Delete() {
  zle vi-vis-key-reset
  CURSOR=$(($CURSOR + 1))
  zle kill-buffer
}
#
zle -N vi-vis-yank
function vi-vis-yank() {
  zle vi-vis-key-reset
  CURSOR=$(($CURSOR + 1))
  zle kill-region
  zle vi-put-before
}
#
zle -N vi-vis-Yank
function vi-vis-Yank() {
  zle vi-vis-key-reset
  zle vi-yank-whole-line
}
#
zle -N vi-vis-change
function vi-vis-change() {
  zle vi-vis-key-reset
  CURSOR=$(($CURSOR + 1))
  zle kill-region
  zle vi-insert
}
#
zle -N vi-vis-Change
function vi-vis-Change() {
  zle vi-vis-key-reset
  zle kill-buffer
  zle vi-insert
}
#
zle -N vi-vis-paste
function vi-vis-paste() {
  zle vi-vis-key-reset
  zle vi-put-after
}
#
zle -N vi-vis-Paste
function vi-vis-Paste() {
  zle vi-vis-key-reset
  zle vi-put-before
}
#
zle -N vi-vis-open
function vi-vis-open() {
  CURSOR_MARK_TMP=$MARK
  MARK=$(($CURSOR + 1))
  CURSOR=$(( ${CURSOR_MARK_TMP} - 1))
}
#
##########################################################
#
zle -N vi-vis-add
function vi-vis-add() {
  zle vi-vis-key-reset
  if [ $CURSOR -lt $MARK ] ;then 
    CURSOR=$(($CURSOR + 1))
  fi
  MARK=$(($CURSOR + 1))
  zle vi-vis-key-reset
  zle vi-add-next
}
#
zle -N vi-vis-Add
function vi-vis-Add() {
  zle vi-vis-key-reset
  zle vi-end-of-line
  MARK=$(($CURSOR + 1))
  zle vi-add-eol
}
#
zle -N vi-vis-insert
function vi-vis-insert() {
  zle vi-vis-key-reset
  if [ $CURSOR -lt $MARK ] ;then 
    CURSOR=$(($CURSOR + 1))
  fi
  MARK=$(($CURSOR + 1))
  zle vi-vis-key-reset
  zle vi-insert
}
#
zle -N vi-vis-Insert
function vi-vis-Insert() {
  zle vi-vis-key-reset
  zle vi-digit-or-beginning-of-line
  MARK=$CURSOR
  zle vi-insert-bol
}
#
##########################################################
#
zle -N vi-vis-undo
function vi-vis-undo() {
  zle vi-vis-key-reset
  zle vi-undo-change
}
#
zle -N vi-vis-repeat
function vi-vis-repeat() {
  zle vi-vis-key-reset
  zle vi-repeat-change
}
#
zle -N vi-vis-reset
function vi-vis-reset() {
  zle vi-vis-key-reset
  zle vi-cmd-mode
}
zle -N vi-vis-reset
function vi-vis-reset() {
  if [ ${VI_VIS_MODE} -eq 2 ] ;then
    CURSOR=$CURSOR_V_START
  fi
  zle vi-vis-key-reset
  zle vi-cmd-mode
}
