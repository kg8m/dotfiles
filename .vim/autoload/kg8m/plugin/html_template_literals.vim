vim9script

def kg8m#plugin#html_template_literals#configure(): void  # {{{
  g:htl_css_templates = v:true
  g:htl_all_templates = v:false

  kg8m#plugin#configure({
    depends: "vim-javascript",
  })

  kg8m#plugin#register("pangloss/vim-javascript")
enddef  # }}}
