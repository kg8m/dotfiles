function kg8m#plugin#markdown#configure() abort  " {{{
  let g:vim_markdown_override_foldtext         = v:false
  let g:vim_markdown_no_default_key_mappings   = v:true
  let g:vim_markdown_conceal                   = v:false
  let g:vim_markdown_no_extensions_in_markdown = v:true
  let g:vim_markdown_autowrite                 = v:true
  let g:vim_markdown_folding_level             = 10

  call kg8m#plugin#configure(#{
  \   lazy:    v:true,
  \   depends: "vim-markdown-quote-syntax",
  \   on_ft:   "markdown",
  \ })

  if kg8m#plugin#register("joker1007/vim-markdown-quote-syntax")  " {{{
    let g:markdown_quote_syntax_filetypes = #{
    \    css:  #{ start: '\%(css\|scss\|sass\)' },
    \    haml: #{ start: "haml" },
    \    xml:  #{ start: "xml" },
    \ }

    call kg8m#plugin#configure(#{
    \   lazy: v:true,
    \ })
  endif  " }}}
endfunction  " }}}
