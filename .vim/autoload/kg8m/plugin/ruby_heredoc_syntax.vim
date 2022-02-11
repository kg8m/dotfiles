vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:  true,
    on_ft: "ruby",
    hook_source: () => OnSource(),
  })
enddef

def OnSource(): void
  # Default: JS, SQL, HTML
  g:ruby_heredoc_syntax_filetypes = {
    haml: { start: "HAML" },
    ruby: { start: "RUBY" },
  }
enddef
