vim9script

def kg8m#plugin#markdown#configure(): void
  g:vim_markdown_override_foldtext         = false
  g:vim_markdown_no_default_key_mappings   = true
  g:vim_markdown_conceal                   = false
  g:vim_markdown_no_extensions_in_markdown = true
  g:vim_markdown_autowrite                 = true
  g:vim_markdown_folding_level             = 10

  kg8m#plugin#configure({
    lazy:    true,
    depends: "vim-markdown-quote-syntax",
    on_ft:   "markdown",
  })

  if kg8m#plugin#register("joker1007/vim-markdown-quote-syntax")
    g:markdown_quote_syntax_filetypes = {
       css:  { start: '\%(css\|scss\|sass\)' },
       haml: { start: "haml" },
       xml:  { start: "xml" },
    }

    kg8m#plugin#configure({
      lazy: true,
    })
  endif
enddef
