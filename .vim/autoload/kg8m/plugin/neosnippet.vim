let s:script_filepath = expand("<sfile>")

function kg8m#plugin#neosnippet#configure() abort  " {{{
  " `on_ft` for Syntaxes
  call kg8m#plugin#configure(#{
  \   lazy:      v:true,
  \   on_ft:     ["snippet", "neosnippet"],
  \   on_func:   "neosnippet#",
  \   on_source: "asyncomplete.vim",
  \   hook_source:      function("s:on_source"),
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:setup_contextual() abort  " {{{
  let dir = s:snippets_dirpath().."/"
  let g:neosnippet_contextual#contexts = get(g:, "neosnippet_contextual#contexts", {})

  if !has_key(g:neosnippet_contextual#contexts, "ruby")
    let g:neosnippet_contextual#contexts.ruby = []
  endif

  if kg8m#util#on_rails_dir()
    let g:neosnippet_contextual#contexts.ruby += [
    \   #{ pattern: '^app/controllers', snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-controller.snip"] },
    \   #{ pattern: '^app/models',      snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-model.snip"] },
    \   #{ pattern: '^db/migrate',      snippets: [dir.."ruby-rails.snip",    dir.."ruby-rails-migration.snip"] },
    \   #{ pattern: '_test\.rb$',       snippets: [dir.."ruby-minitest.snip", dir.."ruby-rails.snip", dir.."ruby-rails-test.snip", dir.."ruby-rails-minitest.snip"] },
    \   #{ pattern: '_spec\.rb$',       snippets: [dir.."ruby-rspec.snip",    dir.."ruby-rails.snip", dir.."ruby-rails-test.snip", dir.."ruby-rails-rspec.snip"] },
    \ ]
  else
    let g:neosnippet_contextual#contexts.ruby += [
    \   #{ pattern: '_test\.rb$', snippets: [dir.."ruby-minitest.snip"] },
    \   #{ pattern: '_spec\.rb$', snippets: [dir.."ruby-rspec.snip"] },
    \ ]
  endif

  augroup my_vimrc  " {{{
    execute "autocmd FileType "..join(keys(g:neosnippet_contextual#contexts), ",").." call timer_start(50, { -> s:source_contextual_snippets() })"
  augroup END  " }}}
endfunction  " }}}

function s:source_contextual_snippets() abort  " {{{
  let contexts = get(g:neosnippet_contextual#contexts, &filetype, [])
  let filepath = kg8m#util#current_relative_path()

  for context in contexts
    if filepath =~# context.pattern
      for snippet in context.snippets
        if filereadable(snippet)
          execute "NeoSnippetSource "..snippet
        endif
      endfor

      return
    endif
  endfor
endfunction  " }}}

function s:snippets_dirpath() abort  " {{{
  if !has_key(s:, "snippets_dirpath")
    let s:snippets_dirpath = fnamemodify(s:script_filepath, ":h:h:h:h").."/snippets"
  endif

  return s:snippets_dirpath
endfunction  " }}}

function s:on_source() abort  " {{{
  call kg8m#plugin#completion#define_mappings()

  let g:neosnippet#snippets_directory = [
  \   s:snippets_dirpath(),
  \ ]
  let g:neosnippet#disable_runtime_snippets = #{
  \   _: v:true,
  \ }

  augroup my_vimrc  " {{{
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END  " }}}

  call s:setup_contextual()
endfunction  " }}}

function s:on_post_source() abort  " {{{
  call timer_start(0, { -> s:source_contextual_snippets() })
endfunction  " }}}
