function kg8m#plugin#asyncomplete#nextword#configure() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd User asyncomplete_setup call s:setup()
  augroup END  " }}}

  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   depends:   "async.vim",
  \   on_source: "asyncomplete.vim",
  \ })

  if kg8m#plugin#register("prabirshrestha/async.vim")  " {{{
    call kg8m#plugin#configure(#{
    \   lazy: v:true,
    \ })
  endif  " }}}
endfunction  " }}}

function s:setup() abort  " {{{
  " Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  call asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options(#{
  \   name: "nextword",
  \   allowlist: ["*"],
  \   args: ["-n", "10000"],
  \   completor: function("asyncomplete#sources#nextword#completor"),
  \   priority: 3,
  \ }))
endfunction  " }}}
