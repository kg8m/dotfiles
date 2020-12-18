vim9script

const s:script_filepath = expand("<sfile>")

var s:snippets_dirpath: string

def kg8m#plugin#neosnippet#configure(): void  # {{{
  # `on_ft` for Syntaxes
  kg8m#plugin#configure({
    lazy:  v:true,
    on_ft: ["snippet", "neosnippet"],
    on_i:  v:true,
    hook_source:      function("s:on_source"),
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

def s:setup_contextual(): void  # {{{
  const dir = s:snippets_dirpath() .. "/"
  g:neosnippet_contextual#contexts = get(g:, "neosnippet_contextual#contexts", {})

  if !has_key(g:neosnippet_contextual#contexts, "ruby")
    g:neosnippet_contextual#contexts.ruby = []
  endif

  if kg8m#util#on_rails_dir()
    extend(g:neosnippet_contextual#contexts.ruby, [
      { pattern: '^app/controllers', snippets: [dir .. "ruby-rails.snip",    dir .. "ruby-rails-controller.snip"] },
      { pattern: '^app/models',      snippets: [dir .. "ruby-rails.snip",    dir .. "ruby-rails-model.snip"] },
      { pattern: '^db/migrate',      snippets: [dir .. "ruby-rails.snip",    dir .. "ruby-rails-migration.snip"] },
      { pattern: '_test\.rb$',       snippets: [dir .. "ruby-minitest.snip", dir .. "ruby-rails.snip", dir .. "ruby-rails-test.snip", dir .. "ruby-rails-minitest.snip"] },
      { pattern: '_spec\.rb$',       snippets: [dir .. "ruby-rspec.snip",    dir .. "ruby-rails.snip", dir .. "ruby-rails-test.snip", dir .. "ruby-rails-rspec.snip"] },
    ])
  else
    extend(g:neosnippet_contextual#contexts.ruby, [
      { pattern: '_test\.rb$', snippets: [dir .. "ruby-minitest.snip"] },
      { pattern: '_spec\.rb$', snippets: [dir .. "ruby-rspec.snip"] },
    ])
  endif

  augroup my_vimrc  # {{{
    execute "autocmd FileType " .. join(keys(g:neosnippet_contextual#contexts), ",") .. " timer_start(50, { -> s:source_contextual_snippets() })"
  augroup END  # }}}
enddef  # }}}

def s:source_contextual_snippets(): void  # {{{
  const contexts = get(g:neosnippet_contextual#contexts, &filetype, [])
  const filepath = kg8m#util#current_relative_path()

  for context in contexts
    if filepath =~# context.pattern
      for snippet in context.snippets
        if filereadable(snippet)
          execute "NeoSnippetSource " .. snippet
        endif
      endfor

      return
    endif
  endfor
enddef  # }}}

def s:snippets_dirpath(): string  # {{{
  if empty(s:snippets_dirpath)
    s:snippets_dirpath = fnamemodify(s:script_filepath, ":h:h:h:h") .. "/snippets"
  endif

  return s:snippets_dirpath
enddef  # }}}

def s:on_source(): void  # {{{
  kg8m#plugin#completion#define_mappings()

  g:neosnippet#snippets_directory = [
    s:snippets_dirpath(),
  ]
  g:neosnippet#disable_runtime_snippets = {
    _: v:true,
  }

  augroup my_vimrc  # {{{
    autocmd InsertLeave * NeoSnippetClearMarkers
  augroup END  # }}}

  s:setup_contextual()
enddef  # }}}

def s:on_post_source(): void  # {{{
  timer_start(0, { -> s:source_contextual_snippets() })
enddef  # }}}
