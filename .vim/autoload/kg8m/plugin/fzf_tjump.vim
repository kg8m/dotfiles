function kg8m#plugin#fzf_tjump#configure() abort  " {{{
  let g:fzf_tjump_path_to_preview_bin = kg8m#plugin#get_info("fzf.vim").path.."/bin/preview.sh"

  nnoremap <Leader><Leader>t :FzfTjump<Space>
  vnoremap <Leader><Leader>t "gy:FzfTjump<Space><C-r>"

  map g] <Plug>(fzf-tjump)

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   on_cmd:  "FzfTjump",
  \   on_func: "fzf_tjump#jump",
  \   on_map:  [["nv", "<Plug>(fzf-tjump)"]],
  \   depends: "fzf.vim",
  \ })
endfunction  " }}}
