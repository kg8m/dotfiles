vim9script

def kg8m#plugin#asyncomplete#file#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd User asyncomplete_setup timer_start(0, { -> s:setup() })
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:      true,
    on_source: "asyncomplete.vim",
  })
enddef  # }}}

def s:setup(): void  # {{{
  asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    name: "file",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#file#completor"),
    priority: 3,
  }))
enddef  # }}}
