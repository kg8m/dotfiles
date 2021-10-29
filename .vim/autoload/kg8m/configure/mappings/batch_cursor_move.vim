vim9script

var s:timer_id = -1
var s:current_key = ""
var s:count = 0

# :h mode()
#   n*:  Normal or Operator-pending
#   v*:  Visual
#   ^V*: Visual blockwise
#   s*:  Select
#   ^S:  Select blockwise
const MODE_PATTERN = "^[nvs\<C-v>\<C-s>]"

# Move cursor in batches because Vim sometimes gets too slow at moving cursor, e.g., when hlsearch is set.
def kg8m#configure#mappings#batch_cursor_move#define(): void
  noremap <expr> j     <SID>trigger("j")
  noremap <expr> k     <SID>trigger("k")
  noremap <expr> h     <SID>trigger("h")
  noremap <expr> l     <SID>trigger("l")
  noremap <expr> <C-e> <SID>trigger("<C-e>")
  noremap <expr> <C-y> <SID>trigger("<C-y>")
enddef

def s:trigger(key: string): string
  timer_stop(s:timer_id)

  if v:count !=# 0
    s:release()
    return key
  endif

  if key ==# s:current_key
    if s:count >=# 5
      s:release()
    else
      s:count += 1
    endif
  else
    if s:count ># 0
      s:release()
    endif

    s:count += 1
  endif

  s:current_key = key
  s:timer_id = timer_start(50, (_) => s:release())

  return ""
enddef

def s:release(): void
  if s:count ># 0 && mode() =~? MODE_PATTERN
    # `n` for preventing remap. `t` for opening folds.
    feedkeys(s:count .. s:current_key, "nt")
  endif

  s:current_key = ""
  s:count = 0
enddef
