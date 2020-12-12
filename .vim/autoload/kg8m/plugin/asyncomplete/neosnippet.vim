function kg8m#plugin#asyncomplete#neosnippet#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:setup()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_source: "asyncomplete.vim",
  \ })
endfunction  " }}}

function s:setup() abort  " {{{
  call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options(#{
  \   name: "neosnippet",
  \   allowlist: ["*"],
  \   completor: function("asyncomplete#sources#neosnippet#completor"),
  \   priority: 1,
  \ }))
endfunction  " }}}
