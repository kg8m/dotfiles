vim9script

def kg8m#plugin#vsnip#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy: v:true,
    on_i: v:true,
    hook_source: function("s:on_source"),
  })

  if kg8m#plugin#register("hrsh7th/vim-vsnip-integ")  # {{{
    kg8m#plugin#configure({
      lazy:      v:true,
      on_source: "vim-vsnip",
    })
  endif  # }}}
enddef  # }}}

def s:on_source(): void  # {{{
  kg8m#plugin#completion#define_mappings()
enddef  # }}}
