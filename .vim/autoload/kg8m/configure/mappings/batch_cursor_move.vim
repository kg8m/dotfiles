vim9script

var s:timer_id = -1
var s:current_key = ""
var s:count = 0

# Move cursor in batches because Vim sometimes gets too slow at moving cursor, e.g., when hlsearch is set.
def kg8m#configure#mappings#batch_cursor_move#define(): void
  noremap <expr> j     <SID>run("j")
  noremap <expr> k     <SID>run("k")
  noremap <expr> h     <SID>run("h")
  noremap <expr> l     <SID>run("l")
  noremap <expr> <C-e> <SID>run("<C-e>")
  noremap <expr> <C-y> <SID>run("<C-y>")
enddef

def s:run(key: string): string
  timer_stop(s:timer_id)

  if v:count !=# 0
    s:teardown()
    return key
  endif

  if key ==# s:current_key
    if s:count >=# 5
      s:teardown()
    else
      s:count += 1
    endif
  else
    if s:count ># 0
      s:teardown()
    endif

    s:count += 1
  endif

  s:current_key = key
  s:timer_id = timer_start(50, (_) => s:teardown())

  return ""
enddef

def s:teardown(): void
  if s:count ># 0
    # `n` for preventing remap. `t` for opening folds.
    feedkeys(s:count .. s:current_key, "nt")
  endif

  s:current_key = ""
  s:count = 0
enddef
