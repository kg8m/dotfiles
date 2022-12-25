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

  const all_prepends = get(g:, "neosnippet_contextual_prepends", {})
  const ft_prepends  = get(all_prepends, &filetype, [])
  contexts[&filetype] = ft_prepends

  if &filetype ==# "eruby"
    contexts[&filetype] += ContextsForEruby()
  elseif &filetype ==# "ruby"
    contexts[&filetype] += ContextsForRuby()
  endif
enddef

def ContextsForEruby(): list<dict<any>>
  if kg8m#util#OnRailsDir()
    const common = ["ruby-rails.snip"]
    return [
      { pattern: '\.html\.erb$', snippets: common + ["html.snip", "javascript.snip"] },
      { pattern: '\.js\.erb$',   snippets: common + ["javascript.snip"] },
    ]
  else
    return []
  endif
enddef

def ContextsForRuby(): list<dict<any>>
  if kg8m#util#OnRailsDir()
    const common = ["ruby-rails.snip"]
    return [
      { pattern: '^app/controllers', snippets: common + ["ruby-rails-controller.snip"] },
      { pattern: '^app/models',      snippets: common + ["ruby-rails-model.snip"] },
      { pattern: '^db/migrate',      snippets: common + ["ruby-rails-migration.snip"] },
      { pattern: '_spec\.rb$',       snippets: common + ["ruby-rspec.snip", "ruby-rails-rspec.snip"] },
      { pattern: '_test\.rb$',       snippets: common + ["ruby-minitest.snip", "ruby-rails-minitest.snip"] },
      { pattern: '.',                snippets: common },
    ]
  else
    return [
      { pattern: '_test\.rb$', snippets: ["ruby-minitest.snip"] },
      { pattern: '_spec\.rb$', snippets: ["ruby-rspec.snip"] },
    ]
  endif
enddef
