" http://vim-users.jp/2010/01/hack120/

let s:old_filepath = expand("~/.vim/.vimwinpos")
let s:filepath = expand("~/.vim/gui-window-info")

if filereadable(s:old_filepath)
  call rename(s:old_filepath, s:filepath)
endif

function kg8m#configure#gui#window_size#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd VimLeavePre * call s:save()
  augroup END  " }}}

  if has("vim_starting") && filereadable(s:filepath)
    execute "source "..s:filepath
  endif
endfunction  " }}}

function s:save() abort  " {{{
  let options = [
  \   "set columns="..&columns,
  \   "set lines="..&lines,
  \   "winpos "..getwinposx().." "..getwinposy(),
  \ ]

  call writefile(options, s:filepath)
endfunction  " }}}