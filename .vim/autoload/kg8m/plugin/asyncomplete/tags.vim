vim9script

def kg8m#plugin#asyncomplete#tags#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd User asyncomplete_setup timer_start(0, { -> s:setup() })
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:      v:true,
    on_source: "asyncomplete.vim",
  })
enddef  # }}}

def s:setup(): void  # {{{
  asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
    name: "tags",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tags#completor"),
    priority: 3,
  }))
enddef  # }}}
