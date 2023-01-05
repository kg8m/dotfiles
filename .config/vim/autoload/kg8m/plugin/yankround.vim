vim9script

import autoload "kg8m/plugin.vim"

export def OnSource(): void
  g:yankround_dir           = $"{$XDG_DATA_HOME}/vim/yankround"
  g:yankround_max_history   = 500
  g:yankround_use_region_hl = true

  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)

  nmap <expr> <C-p> yankround#is_active() ? "<Plug>(yankround-prev)" : "<C-p>"
  nmap <expr> <C-n> yankround#is_active() ? "<Plug>(yankround-next)" : "<C-n>"
enddef

export def Cache(): list<string>
  plugin.EnsureSourced("yankround.vim")
  return g:_yankround_cache
enddef

export def CacheAndRegtype(index: number): list<string>
  plugin.EnsureSourced("yankround.vim")
  return yankround#_get_cache_and_regtype(index)
enddef
