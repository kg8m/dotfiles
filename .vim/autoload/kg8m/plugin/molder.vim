vim9script

def kg8m#plugin#molder#configure(): void
  nnoremap <silent> <Leader>e :call <SID>run()<CR>

  kg8m#plugin#configure({
    lazy:     true,
    on_start: true,
    hook_source: () => s:on_source(),
  })
enddef

def s:run(): void
  kg8m#plugin#ensure_sourced("vim-molder")

  if expand("%")->empty()
    edit .
  else
    edit %:h
  endif
enddef

def s:setup_buffer(): void
  # Cancel molder
  nnoremap <buffer> q     <C-o>
  nnoremap <buffer> <C-c> <C-o>
enddef

def s:on_source(): void
  g:molder_show_hidden = true

  augroup vimrc-plugin-molder
    autocmd!
    autocmd FileType molder s:setup_buffer()
  augroup END
enddef
