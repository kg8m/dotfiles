function kg8m#plugin#asyncomplete#tabnine#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:setup()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_source: "asyncomplete.vim",
  \ })
endfunction  " }}}

function s:setup() abort  " {{{
  call asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options(#{
  \   name: "tabnine",
  \   allowlist: ["*"],
  \   completor: function("asyncomplete#sources#tabnine#completor"),
  \   priority: 0,
  \ }))
endfunction  " }}}
