vim9script

def kg8m#plugin#ruby_heredoc_syntax#configure(): void
  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "ruby",
    hook_source: () => s:on_source(),
  })
enddef

def s:on_source(): void
  # Default: JS, SQL, HTML
  g:ruby_heredoc_syntax_filetypes = {
    haml: { start: "HAML" },
    ruby: { start: "RUBY" },
  }
enddef
