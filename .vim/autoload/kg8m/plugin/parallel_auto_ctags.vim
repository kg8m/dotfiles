function kg8m#plugin#parallel_auto_ctags#configure() abort  " {{{
  let &tags .= ","..kg8m#util#rubygems_path().."/../tags"

  let g:parallel_auto_ctags#options      = ["--fields=n", "--tag-relative=yes", "--recurse=yes", "--sort=yes", "--exclude=.vim-sessions"]
  let g:parallel_auto_ctags#entry_points = #{
  \   pwd:  #{
  \     path:    ".",
  \     options: g:parallel_auto_ctags#options + ["--exclude=node_modules", "--exclude=vendor/bundle", "--languages=-rspec"],
  \     events:  ["VimEnter", "BufWritePost"],
  \     silent:  v:false,
  \   },
  \   gems: #{
  \     path:    kg8m#util#rubygems_path().."/..",
  \     options: g:parallel_auto_ctags#options + ["--exclude=test", "--exclude=spec", "--languages=ruby"],
  \     events:  ["VimEnter"],
  \     silent:  v:false,
  \   },
  \ }
endfunction  " }}}