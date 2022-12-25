vim9script

final contexts: dict<list<dict<any>>> = {}

export def Setup(): void
  augroup vimrc-plugin-neosnippet-contextual
    autocmd!
    autocmd FileType * timer_start(50, (_) => kg8m#plugin#neosnippet#contextual#Source())
  augroup END
enddef

export def Source(): void
  SetupContexts()

  const current_path = kg8m#util#file#CurrentRelativePath()

  for context in get(contexts, &filetype, [])
    if current_path =~# context.pattern
      for snippet in context.snippets
        SourceSnippet(snippet)
      endfor

      break
    endif
  endfor
enddef

def SourceSnippet(filename: string): void
  const filepath = printf("%s/%s", kg8m#plugin#neosnippet#SnippetsDirpath(), filename)

  if filereadable(filepath)
    execute "NeoSnippetSource" fnameescape(filepath)
  endif
enddef

def SetupContexts(): void
  if has_key(contexts, &filetype)
    return
  endif

  if &filetype ==# "ruby"
    SetupContextsForRuby()
  endif
enddef

def SetupContextsForRuby(): void
  if kg8m#util#OnRailsDir()
    const common = ["ruby-rails.snip"]
    contexts.ruby = [
      { pattern: '\.html\.erb$',     snippets: common + ["html.snip", "javascript.snip"] },
      { pattern: '\.js\.erb$',       snippets: common + ["javascript.snip"] },
      { pattern: '^app/controllers', snippets: common + ["ruby-rails-controller.snip"] },
      { pattern: '^app/models',      snippets: common + ["ruby-rails-model.snip"] },
      { pattern: '^db/migrate',      snippets: common + ["ruby-rails-migration.snip"] },
      { pattern: '_spec\.rb$',       snippets: common + ["ruby-rspec.snip", "ruby-rails-rspec.snip"] },
      { pattern: '_test\.rb$',       snippets: common + ["ruby-minitest.snip", "ruby-rails-minitest.snip"] },
      { pattern: '.',                snippets: common },
    ]
  else
    contexts.ruby = [
      { pattern: '_test\.rb$', snippets: ["ruby-minitest.snip"] },
      { pattern: '_spec\.rb$', snippets: ["ruby-rspec.snip"] },
    ]
  endif
enddef
