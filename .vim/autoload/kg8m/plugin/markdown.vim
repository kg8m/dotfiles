vim9script

def kg8m#plugin#markdown#configure(): void
  # Disable folding because it is too heavy
  g:vim_markdown_folding_disabled = true

  g:vim_markdown_no_default_key_mappings   = true
  g:vim_markdown_conceal                   = false
  g:vim_markdown_no_extensions_in_markdown = true
  g:vim_markdown_autowrite                 = true

  kg8m#plugin#configure({
    lazy:    true,
    on_ft:   "markdown",
    depends: "vim-markdown-quote-syntax",
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
