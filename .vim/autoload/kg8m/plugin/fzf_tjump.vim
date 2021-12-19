vim9script

def kg8m#plugin#fzf_tjump#configure()
  g:fzf_tjump_preview_options     = "down:75%:wrap:nohidden:+{3}-/2"
  g:fzf_tjump_path_to_preview_bin = kg8m#plugin#get_info("fzf.vim").path .. "/bin/preview.sh"

  nnoremap <Leader><Leader>t :FzfTjump<Space>
  xnoremap <Leader><Leader>t "zy:FzfTjump<Space><C-r>z

  map g] <Plug>(fzf-tjump)

  kg8m#plugin#configure({
    lazy:    true,
    on_cmd:  "FzfTjump",
    on_map:  { nx: "<Plug>(fzf-tjump)" },
    depends: "fzf.vim",
  })
enddef

def kg8m#plugin#fzf_tjump#run(): void
  kg8m#plugin#ensure_sourced("vim-fzf-tjump")
  fzf_tjump#jump()
enddef
