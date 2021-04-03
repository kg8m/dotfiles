vim9script

def kg8m#plugin#fetch#configure(): void
  augroup my_vimrc
    autocmd VimEnter * s:disable_default_mappings()
  augroup END
enddef

# Disable vim-fetch's `gF` mappings because it conflicts with other plugins
def s:disable_default_mappings(): void
  nmap gF <Plug>(gf-user-gF)
  xmap gF <Plug>(gf-user-gF)
enddef
