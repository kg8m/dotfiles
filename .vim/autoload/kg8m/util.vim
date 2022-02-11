vim9script

final s:cache = {}

export def SourceLocalVimrc(): void
  const filepath = expand("~/.config/vim.local/.vimrc.local")

  if filereadable(filepath)
    execute "source " .. filepath
  endif
enddef

export def OnTmux(): bool
  return !!exists("$TMUX")
enddef

export def OnRailsDir(): bool
  if has_key(s:cache, "on_rails_dir")
    return s:cache.on_rails_dir
  endif

  s:cache.on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:cache.on_rails_dir
enddef

export def IsCtagsAvailable(): bool
  if has_key(s:cache, "is_ctags_available")
    return s:cache.is_ctags_available
  endif

  s:cache.is_ctags_available = !empty($CTAGS_AVAILABLE)
  return s:cache.is_ctags_available
enddef

export def IsGitTmpEdit(): bool
  return kg8m#util#IsGitCommit() || kg8m#util#IsGitHunkEdit() || kg8m#util#IsGitRebase()
enddef

export def IsGitCommit(): bool
  if has_key(s:cache, "is_git_commit")
    return s:cache.is_git_commit
  endif

  s:cache.is_git_commit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/COMMIT_EDITMSG$')
  return s:cache.is_git_commit
enddef

export def IsGitHunkEdit(): bool
  if has_key(s:cache, "is_git_hunk_edit")
    return s:cache.is_git_hunk_edit
  endif

  s:cache.is_git_hunk_edit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/addp-hunk-edit\.diff$')
  return s:cache.is_git_hunk_edit
enddef

export def IsGitRebase(): bool
  if has_key(s:cache, "is_git_rebase")
    return s:cache.is_git_rebase
  endif

  s:cache.is_git_rebase = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/rebase-merge/git-rebase-todo$')
  return s:cache.is_git_rebase
enddef

export def RubygemsPath(): string
  if has_key(s:cache, "rubygems_path")
    return s:cache.rubygems_path
  endif

  if exists("$RUBYGEMS_PATH")
    s:cache.rubygems_path = $RUBYGEMS_PATH
  else
    const command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
    const command = command_prefix .. " -e 'print Gem.path.join(\"\\n\")'"
    const dirpaths = split(system(command), '\n')

    var rubygems_path = ""

    for dirpath in dirpaths
      if isdirectory(dirpath)
        rubygems_path = dirpath .. "/gems"
        break
      endif
    endfor

    if rubygems_path !=# ""
      s:cache.rubygems_path = rubygems_path
    else
      throw "Path to Ruby Gems not found. Candidates: " .. string(dirpaths)
    endif
  endif

  return s:cache.rubygems_path
enddef

export def RemoteCopy(original_text: string): void
  const text = original_text->substitute('\n$', "", "")
  system("ssh main -t 'LC_CTYPE=UTF-8 pbcopy'", text)

  var message = "Copied"
  const max_width = v:echospace - 60

  if max_width ># 10
    # Pass partial text to Vital's `truncate()` because the function is too heavy if the text is large.
    const truncated = kg8m#util#string#Vital().truncate(text[0 : max_width], max_width)->trim()

    message ..= printf(": %s", truncated .. (truncated ==# trim(text) ? "" : "..."))
  endif

  kg8m#util#logger#Info(message)
enddef

export def RemoveTrailingWhitespaces()
  const position = getpos(".")
  keeppatterns :'<,'>s/\s\+$//ge
  setpos(".", position)
enddef

export def JapaneseMatchpairs(): list<list<string>>
  return [
    ["（", "）"],
    ["「", "」"],
    ["『", "』"],
    ["｛", "｝"],
    ["［", "］"],
    ["〈", "〉"],
    ["《", "》"],
    ["【", "】"],
    ["〔", "〕"],
    ["“", "”"],
    ["‘", "’"],
  ]
enddef

export def ConvertToVim9script(): void
  if getline(1) !=# "vim9script"
    append(0, ["vim9script", ""])
  endif

  # Replace `function` with `def` and remove `abort`
  :%s/\v^(\s*)function>!?/\1def/Ie
  :%s/\v^(\s*)endfunction>/\1enddef/Ie
  :%s/\v\) abort>/)/Ie

  # Add function's return type and argument's type
  :%s/\v^(\s*)def ([a-zA-Z&:#_.]+)\((\w+)(.*)\)$/\1def \2(\3: FIXME\4): void/Ie
  :%s/\v^(\s*)def ([a-zA-Z&:#_.]+)\(\)$/\1def \2(): void/Ie

  # Remove `call` except for:
  #   - :call foo()
  #   - <Cmd>call foo()
  #   - "call foo()"
  #   - 'call foo()'
  :%s/\v(:)@<!(\<Cmd\>)@<!(")@<!(')@<!<call\s+//Ie

  # Replace `let foo .= bar` with `let foo ..= bar`
  :%s/\v<(let\s+)([a-zA-Z&:#_.]+)(\s+)\.\=/\1\2\3..=/Ie

  # Replace `let` with `const`
  :%s/\v(:)@<!<let(\s+)([bgsw]:)@!/const\2/Ie

  # Remove `let`
  :%s/\v(:)@<!<let\s+([bgsw]:)/\2/Ie

  # Replace `is#` and `isnot#`
  :%s/\v<is(#?)/==\1/gIe
  :%s/\v<isnot(#?)/!=\1/gIe

  # Remove `#` from dictionary literals
  :%s/\v#\{/{/ge

  # Add white spaces around `..`
  :%s/\v([^.\/ ])\.\.%(\.)@!/\1 ../ge
  :%s/\v%(\.)@<!\.\.([^.\/ ])@<!\=/.. \1/ge

  # Replace comment symbols `"` with `#`
  :%s/\v^(\s*)" /\1# /e
  :%s/\v" \{\{\{/# {{{/e
  :%s/\v" \}\}\}/# }}}/e

  # Remove line continuation symbols (`\`)
  :%s/\v^(\s*)\\ /\1/e

  # Reset some configurations
  set filetype=vim

  echomsg "Fix argument types and return types of functions."
  echomsg "Remove `a:` namespace from argument variables names with attention to `l:` or `s:` namespaced same name variables."
  echomsg "Remove `l:` namespace from variable names with attention to `s:` namespaced same name variables."

  echomsg "Convert extracting string parts as following:"
  echomsg "  - string[i]       => strpart(string, i, 1)"
  echomsg "  - string[i : ]    => strpart(string, i)"
  echomsg "  - string[-i : ]   => strpart(string, len(string) - i)"
  echomsg "  - string[ : i]    => strpart(string, 0, i + 1)"
  echomsg "  - string[ : -i]   => strpart(string, 0, len(string) - i + 1)"
  echomsg "  - string[i : j]   => strpart(string, i, j - i + 1)"
  echomsg "  - string[i : -j]  => strpart(string, i, len(string) - i - j + 1)"
  echomsg "  - string[-i : -j] => strpart(string, len(string) - i, i - j + 1)"
enddef

export def SetupDemo(): void
  set foldcolumn=0
  set signcolumn=no
  lightline#disable()
enddef
