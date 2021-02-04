vim9script

def kg8m#plugin#rails#configure(): void
  if !has_key(g:, "rails_projections")
    g:rails_projections = {}
  endif

  g:rails_projections["script/*.rb"] = { test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  g:rails_projections["script/*"]    = { test: ["test/script/{}_test.rb", "spec/script/{}_spec.rb"] }
  g:rails_projections["test/script/*_test.rb"] = { alternate: ["script/{}", "script/{}.rb"] }
  g:rails_projections["spec/script/*_spec.rb"] = { alternate: ["script/{}", "script/{}.rb"] }

  if !has_key(g:, "rails_path_additions")
    g:rails_path_additions = []
  endif

  if isdirectory("spec/support")
    g:rails_path_additions += [
      "spec/support",
    ]
  endif

  # Don't load lazily because some features don't work
  kg8m#plugin#configure({
    lazy: false,
  })
enddef
