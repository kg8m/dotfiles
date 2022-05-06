vim9script

export def Define(): void
  nnoremap <expr> <Leader>/ <SID>ClearHlsearch()
  nnoremap <expr> /         <SID>EnterSearch()
  cnoremap <expr> <C-c>     <SID>ExitCmdline()
enddef

def ClearHlsearch(): string
  const clear    = ":nohlsearch\<CR>"
  const notify   = ":call kg8m#events#NotifyClearSearchHighlight()\<CR>"
  const teardown = ":echo ''\<CR>"

  return clear .. notify .. teardown
enddef

def EnterSearch(): string
  const enable_highlight      = ":set hlsearch\<CR>"
  const enter_with_very_magic = "/\\v"

  return enable_highlight .. enter_with_very_magic
enddef

def ExitCmdline(): string
  const original = "\<C-c>"

  if getcmdtype() ==# "/"
    return original .. ClearHlsearch()
  else
    return original
  endif
enddef
