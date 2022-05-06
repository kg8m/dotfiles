vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy: true,
    on_event: ["InsertEnter"],
    hook_post_source: () => OnPostSource(),
  })

  if kg8m#plugin#Register("hrsh7th/vim-vsnip-integ")
    kg8m#plugin#Configure({
      lazy:      true,
      on_source: "vim-vsnip",
    })
  endif
enddef

def OnPostSource(): void
  timer_start(0, (_) => kg8m#events#NotifyInsertModePluginLoaded())
enddef
