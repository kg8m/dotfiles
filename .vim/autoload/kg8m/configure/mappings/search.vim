vim9script

def kg8m#configure#mappings#search#define(): void
  nnoremap <expr> <Leader>/ <SID>clear_hlsearch()
  nnoremap <expr> /         <SID>enter_search()
  cnoremap <expr> <C-c>     <SID>exit_cmdline()
enddef

def s:clear_hlsearch(): string
  const clear    = ":nohlsearch\<CR>"
  const notify   = ":call kg8m#events#notify_clear_search_highlight()\<CR>"
  const teardown = ":echo ''\<CR>"

  return clear .. notify .. teardown
enddef

def s:enter_search(): string
  const enable_highlight      = ":set hlsearch\<CR>"
  const enter_with_very_magic = "/\\v"

  return enable_highlight .. enter_with_very_magic
enddef

def s:exit_cmdline(): string
  const original = "\<C-c>"

  if getcmdtype() ==# "/"
    return original .. s:clear_hlsearch()
  else
    return original
  endif
enddef
