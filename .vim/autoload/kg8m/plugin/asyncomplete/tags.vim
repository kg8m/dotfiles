function kg8m#plugin#asyncomplete#tags#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:setup()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_source: "asyncomplete.vim",
  \ })
endfunction  " }}}

function s:setup() abort  " {{{
  call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options(#{
  \   name: "tags",
  \   allowlist: ["*"],
  \   completor: function("asyncomplete#sources#tags#completor"),
  \   priority: 3,
  \ }))
endfunction  " }}}
