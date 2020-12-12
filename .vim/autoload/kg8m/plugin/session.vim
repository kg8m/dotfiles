function kg8m#plugin#session#configure() abort  " {{{
  let g:session_directory         = getcwd().."/.vim-sessions"
  let g:session_autoload          = "no"
  let g:session_autosave          = "no"
  let g:session_autosave_periodic = v:false

  set sessionoptions=buffers,folds

  " Prevent vim-session's `tabpage_filter()` from removing inactive buffers
  set sessionoptions+=tabpages

  augroup my_vimrc  " {{{
    autocmd BufWritePost * silent call s:save()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_cmd:  "SaveSession",
  \   depends: "vim-misc",
  \ })

  if kg8m#plugin#register("xolox/vim-misc")  " {{{
    call kg8m#plugin#configure(#{
    \   lazy: v:true,
    \ })
  endif  " }}}
endfunction  " }}}

function s:save() abort  " {{{
  call kg8m#configure#folding#manual#restore()
  execute "SaveSession "..s:name()
endfunction  " }}}

function s:name() abort  " {{{
  return "%"
  \   ->expand()
  \   ->fnamemodify(":p")
  \   ->substitute("/", "+=", "g")
  \   ->substitute('^\.', "_", "")
endfunction  " }}}
