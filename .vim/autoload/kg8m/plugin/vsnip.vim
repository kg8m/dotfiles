vim9script

def kg8m#plugin#vsnip#configure(): void
  kg8m#plugin#configure({
    lazy: true,
    on_i: true,
    hook_post_source: () => s:on_post_source(),
  })

  if kg8m#plugin#register("hrsh7th/vim-vsnip-integ")
    kg8m#plugin#configure({
      lazy:      true,
      on_source: "vim-vsnip",
    })
  endif
enddef

def s:on_post_source(): void
  timer_start(0, (_) => kg8m#events#notify_insert_mode_plugin_loaded())
enddef
