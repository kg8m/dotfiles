vim9script

def kg8m#plugin#fzf_tjump#configure(): void
  nnoremap <Leader><Leader>t :FzfTjump<Space>
  xnoremap <Leader><Leader>t "zy:FzfTjump<Space><C-r>z

  map g] <Plug>(fzf-tjump)

  kg8m#plugin#configure({
    lazy:    true,
    on_cmd:  "FzfTjump",
    on_map:  { nx: "<Plug>(fzf-tjump)" },
    depends: "fzf.vim",
    hook_source: () => s:on_source(),
  })
enddef

def kg8m#plugin#fzf_tjump#run(): void
  kg8m#plugin#ensure_sourced("vim-fzf-tjump")
  kg8m#plugin#fzf#run(() => fzf_tjump#jump())
enddef

def s:on_source(): void
  g:fzf_tjump_preview_options     = "down:75%:wrap:nohidden:+{3}-/2"
  g:fzf_tjump_path_to_preview_bin = "preview"
enddef
