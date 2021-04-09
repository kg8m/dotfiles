vim9script

def kg8m#plugin#yankround#configure(): void
  g:yankround_dir         = $XDG_DATA_HOME .. "/vim/yankround"
  g:yankround_max_history = 500

  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap <S-p> <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
enddef
