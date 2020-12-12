function kg8m#plugin#vsnip#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_func:   "vsnip#",
  \   on_source: "asyncomplete.vim",
  \   hook_source: function("s:on_source"),
  \ })

  if kg8m#plugin#register("hrsh7th/vim-vsnip-integ")  " {{{
    call kg8m#plugin#configure(#{
    \   lazy:      v:true,
    \   on_source: "vim-vsnip",
    \ })
  endif  " }}}
endfunction  " }}}

function s:on_source() abort  " {{{
  call kg8m#plugin#completion#define_mappings()
endfunction  " }}}
