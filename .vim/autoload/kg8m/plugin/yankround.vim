vim9script

def kg8m#plugin#yankround#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_start: true,
    hook_source: () => s:on_source(),
  })
enddef

def kg8m#plugin#yankround#cache(): list<string>
  kg8m#plugin#ensure_sourced("yankround.vim")
  return g:_yankround_cache
enddef

def kg8m#plugin#yankround#cache_and_regtype(index: number): list<string>
  kg8m#plugin#ensure_sourced("yankround.vim")
  return yankround#_get_cache_and_regtype(index)
enddef

def s:on_source(): void
  g:yankround_dir           = $XDG_DATA_HOME .. "/vim/yankround"
  g:yankround_max_history   = 500
  g:yankround_use_region_hl = true

  nmap p     <Plug>(yankround-p)
  xmap p     <Plug>(yankround-p)
  nmap <S-p> <Plug>(yankround-P)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
enddef
