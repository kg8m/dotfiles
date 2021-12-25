vim9script

final s:contexts: dict<list<dict<any>>> = {}

def kg8m#plugin#neosnippet#contextual#setup(): void
  augroup vimrc-plugin-neosnippet-contextual
    autocmd!
    autocmd FileType * timer_start(50, (_) => kg8m#plugin#neosnippet#contextual#source())
  augroup END
enddef

def kg8m#plugin#neosnippet#contextual#source(): void
  s:setup_contexts()

  const current_path = kg8m#util#file#current_relative_path()

  for context in get(s:contexts, &filetype, [])
    if current_path =~# context.pattern
      for snippet in context.snippets
        s:source_snippet(snippet)
      endfor

      break
    endif
  endfor
enddef

def s:source_snippet(filename: string): void
  const filepath = printf("%s/%s", kg8m#plugin#neosnippet#snippets_dirpath(), filename)

  if filereadable(filepath)
    execute printf("NeoSnippetSource %s", filepath)
  endif
enddef

def s:setup_contexts(): void
  if has_key(s:contexts, &filetype)
    return
  endif

  if &filetype ==# "ruby"
    s:setup_contexts_for_ruby()
  endif
enddef

def s:setup_contexts_for_ruby(): void
  if kg8m#util#on_rails_dir()
    const common = ["ruby-rails.snip"]
    s:contexts.ruby = [
      { pattern: '^app/controllers', snippets: common + ["ruby-rails-controller.snip"] },
      { pattern: '^app/models',      snippets: common + ["ruby-rails-model.snip"] },
      { pattern: '^db/migrate',      snippets: common + ["ruby-rails-migration.snip"] },
      { pattern: '_test\.rb$',       snippets: common + ["ruby-minitest.snip", "ruby-rails-minitest.snip"] },
      { pattern: '_spec\.rb$',       snippets: common + ["ruby-rspec.snip", "ruby-rails-rspec.snip"] },
    ]
  else
    s:contexts.ruby = [
      { pattern: '_test\.rb$', snippets: ["ruby-minitest.snip"] },
      { pattern: '_spec\.rb$', snippets: ["ruby-rspec.snip"] },
    ]
  endif
enddef
