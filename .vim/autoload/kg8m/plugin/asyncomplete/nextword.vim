vim9script

def kg8m#plugin#asyncomplete#nextword#configure(): void  # {{{
  augroup my_vimrc  # {{{
    autocmd User asyncomplete_setup timer_start(0, { -> s:setup() })
  augroup END  # }}}

  kg8m#plugin#configure({
    lazy:      v:true,
    depends:   "async.vim",
    on_source: "asyncomplete.vim",
  })

  if kg8m#plugin#register("prabirshrestha/async.vim")  # {{{
    kg8m#plugin#configure({
      lazy: v:true,
    })
  endif  # }}}
enddef  # }}}

def s:setup(): void  # {{{
  # Should specify filetypes? `allowlist: ["gitcommit", "markdown", "moin", "text"],`
  asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
    name: "nextword",
    allowlist: ["*"],
    args: ["-n", "10000"],
    completor: function("asyncomplete#sources#nextword#completor"),
    priority: 3,
  }))
enddef  # }}}
