vim9script

export def Configure(): void
  nnoremap <Leader><Leader>t :FzfTjump<Space>
  xnoremap <Leader><Leader>t "zy:FzfTjump<Space><C-r>z

  map g] <Plug>(fzf-tjump)

  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  "FzfTjump",
    on_map:  { nx: "<Plug>(fzf-tjump)" },
    depends: "fzf.vim",
    hook_source: () => OnSource(),
  })
enddef

export def Run(): void
  kg8m#plugin#EnsureSourced("vim-fzf-tjump")
  kg8m#plugin#fzf#Run(() => fzf_tjump#jump())
enddef

def OnSource(): void
  g:fzf_tjump_preview_options     = "down:75%:wrap:nohidden:+{3}-/2"
  g:fzf_tjump_path_to_preview_bin = "preview"
enddef
