function kg8m#plugin#ruby_heredoc_syntax#configure() abort  " {{{
  " Default: JS, SQL, HTML
  let g:ruby_heredoc_syntax_filetypes = #{
  \   haml: #{ start: "HAML" },
  \   ruby: #{ start: "RUBY" },
  \ }

  call kg8m#plugin#configure(#{
  \   lazy:  v:true,
  \   on_ft: "ruby",
  \ })
endfunction  " }}}
