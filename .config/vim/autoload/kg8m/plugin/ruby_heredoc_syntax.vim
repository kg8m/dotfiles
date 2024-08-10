vim9script

export def OnSource(): void
  # Default: JS, SQL, HTML
  g:ruby_heredoc_syntax_filetypes = {
    haml: { start: "HAML" },
    ruby: { start: "RUBY" },
    sh: { start: "SH" },
  }
enddef
