function kg8m#plugin#asyncomplete#file#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:setup()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_source: "asyncomplete.vim",
  \ })
endfunction  " }}}

function s:setup() abort  " {{{
  call asyncomplete#register_source(asyncomplete#sources#file#get_source_options(#{
  \   name: "file",
  \   allowlist: ["*"],
  \   completor: function("asyncomplete#sources#file#completor"),
  \   priority: 3,
  \ }))
endfunction  " }}}
