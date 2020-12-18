vim9script

def kg8m#plugin#protocol#configure(): void  # {{{
  # Disable netrw.vim
  g:loaded_netrw             = v:true
  g:loaded_netrwPlugin       = v:true
  g:loaded_netrwSettings     = v:true
  g:loaded_netrwFileHandlers = v:true

  kg8m#plugin#configure({
    lazy:    v:true,
    on_path: '^https\?://',
  })
enddef  # }}}
