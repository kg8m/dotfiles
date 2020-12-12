function kg8m#plugin#html_template_literals#configure() abort  " {{{
  let g:htl_css_templates = v:true
  let g:htl_all_templates = v:false

  call kg8m#plugin#configure(#{
  \   depends: "vim-javascript",
  \ })

  call kg8m#plugin#register("pangloss/vim-javascript")
endfunction  " }}}
