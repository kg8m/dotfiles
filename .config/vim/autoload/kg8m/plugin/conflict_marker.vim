vim9script

final cache = {
  active: false,
  notified: false,
}

# NOTE: `&diff` is always falsy before `VimEnter`.
export def Configure(): void
  augroup vimrc-plugin-conflict_marker
    autocmd!
    autocmd FileType * SetupBuffer()
    autocmd User all_on_start_plugins_sourced NotifyActivated()
  augroup END

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { n: "<Plug>(conflict-marker-" },
    hook_source: () => OnSource(),
  })
enddef

def SetupBuffer(): void
  if &diff
    nmap <buffer> <Leader>c <Plug>(conflict-marker-next-hunk)
    cache.active = true

    if !cache.notified && kg8m#plugin#AreAllOnStartPluginsSourced()
      NotifyActivated()
    endif
  endif
enddef

def NotifyActivated(): void
  if cache.active
    kg8m#util#logger#Info("Press `<Leader>c` to move to next conflict hunk.")
    cache.notified = true
  endif
enddef

def OnSource(): void
  g:conflict_marker_enable_mappings = false
enddef
