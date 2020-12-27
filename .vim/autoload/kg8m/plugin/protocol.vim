vim9script

def kg8m#plugin#protocol#configure(): void  # {{{
  # Disable netrw.vim
  g:loaded_netrw             = true
  g:loaded_netrwPlugin       = true
  g:loaded_netrwSettings     = true
  g:loaded_netrwFileHandlers = true

  kg8m#plugin#configure({
    lazy:    true,
    on_path: '^https\?://',
  })
enddef  # }}}
