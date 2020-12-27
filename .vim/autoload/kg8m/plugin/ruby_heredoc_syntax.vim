vim9script

def kg8m#plugin#ruby_heredoc_syntax#configure(): void  # {{{
  # Default: JS, SQL, HTML
  g:ruby_heredoc_syntax_filetypes = {
    haml: { start: "HAML" },
    ruby: { start: "RUBY" },
  }

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "ruby",
  })
enddef  # }}}
