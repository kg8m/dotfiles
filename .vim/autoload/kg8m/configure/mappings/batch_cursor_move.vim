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
export def Define(): void
  noremap <expr> j     <SID>Trigger("j")
  noremap <expr> k     <SID>Trigger("k")
  noremap <expr> h     <SID>Trigger("h")
  noremap <expr> l     <SID>Trigger("l")
  noremap <expr> <C-e> <SID>Trigger("<C-e>")
  noremap <expr> <C-y> <SID>Trigger("<C-y>")
enddef

def Trigger(key: string): string
  timer_stop(s:timer_id)

  if v:count !=# 0
    Release()
    return key
  endif

  if key ==# s:current_key
    if s:count >=# 5
      Release()
    else
      s:count += 1
    endif
  else
    if s:count ># 0
      Release()
    endif

    s:count += 1
  endif

  s:current_key = key
  s:timer_id = timer_start(50, (_) => Release())

  return ""
enddef

def Release(): void
  if s:count ># 0 && mode() =~? MODE_PATTERN
    # `n` for preventing remap. `t` for opening folds.
    feedkeys(s:count .. s:current_key, "nt")
  endif

  s:current_key = ""
  s:count = 0
enddef
