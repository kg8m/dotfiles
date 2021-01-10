vim9script

def kg8m#plugin#asyncomplete#tabnine#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd User asyncomplete_setup timer_start(0, () => s:setup())
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:      true,
    on_source: "asyncomplete.vim",
  })
enddef  # }}}

def s:setup(): void  # {{{
  asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options({
    name: "tabnine",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tabnine#completor"),
    priority: 0,
  }))
enddef  # }}}
