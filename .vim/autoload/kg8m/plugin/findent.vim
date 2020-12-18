vim9script

def kg8m#plugin#findent#configure(): void  # {{{
  g:findent#enable_messages = v:false
  g:findent#enable_warnings = v:false

  augroup my_vimrc  # {{{
    autocmd FileType * s:run()
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: "Findent",
  })
enddef  # }}}

def s:run(): void  # {{{
  if &filetype !=# "startify"
    Findent
  endif
enddef  # }}}
