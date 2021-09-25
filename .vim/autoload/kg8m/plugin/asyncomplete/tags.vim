vim9script

def kg8m#plugin#asyncomplete#tags#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_event: ["InsertEnter"],
    on_start: true,
    depends:  "asyncomplete.vim",
    hook_post_source: () => s:on_post_source(),
  })
enddef

def s:register(): void
  asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
    name: "tags",
    allowlist: ["*"],
    completor: function("asyncomplete#sources#tags#completor"),
    priority: 3,
  }))
enddef

# Re-register source because completion candidates are not refreshed after updating tags file.
def s:reregister(): void
  asyncomplete#unregister_source("tags")
  s:register()
enddef

def s:on_post_source(): void
  s:register()

  if kg8m#util#is_ctags_available() && !kg8m#util#is_git_tmp_edit()
    augroup my_vimrc
      autocmd User parallel_auto_ctags_finish s:reregister()
    augroup END
  endif
enddef
