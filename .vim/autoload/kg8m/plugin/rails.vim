function kg8m#plugin#rails#configure() abort  " {{{
  if !has_key(g:, "rails_projections")
    let g:rails_projections = {}
  endif

  let g:rails_projections["script/*.rb"] = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["script/*"]    = #{ test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  let g:rails_projections["test/script/*_test.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }
  let g:rails_projections["spec/script/*_spec.rb"] = #{ alternate: ["script/{}", "script/{}.rb"] }

  if !has_key(g:, "rails_path_additions")
    let g:rails_path_additions = []
  endif

  if isdirectory("spec/support")
    let g:rails_path_additions += [
    \   "spec/support",
    \ ]
  endif

  " Don't load lazily because some features don't work
  call kg8m#plugin#configure(#{
  \   lazy: v:false,
  \ })
endfunction  " }}}
