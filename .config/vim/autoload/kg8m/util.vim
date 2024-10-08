vim9script

import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/string.vim" as stringUtil

final cache = {}

export def SourceLocalVimrc(): void
  const filepath = expand("~/.config/vim.local/vimrc.local.vim")

  if filereadable(filepath)
    execute "source" filepath
  endif
enddef

export def OnTmux(): bool
  return !!exists("$TMUX")
enddef

export def OnRailsDir(): bool
  if has_key(cache, "on_rails_dir")
    return cache.on_rails_dir
  endif

  # Support Rails engines.
  cache.on_rails_dir = isdirectory("./app") && (filereadable("./config/environment.rb") || filereadable("./bin/rails"))
  return cache.on_rails_dir
enddef

export def IsCtagsAvailable(): bool
  if has_key(cache, "is_ctags_available")
    return cache.is_ctags_available
  endif

  cache.is_ctags_available = ($USE_CTAGS ==# "1")
  return cache.is_ctags_available
enddef

# cf. .config/bin/is_executable
# NOTE: This function may be a bit slow, so be careful when using it.
export def IsExecutable(command: string): bool
  const binpath = exepath(command)

  if empty(binpath)
    return false
  endif

  if stringUtil.Includes(binpath, "/mise/shims/")
    system($"mise which {command} > /dev/null 2>&1")
    return !v:shell_error
  else
    return false
  endif
enddef

export def IsGitTmpEdit(): bool
  return IsGitCommit() || IsGitHunkEdit() || IsGitRebase()
enddef

export def IsGitCommit(): bool
  if has_key(cache, "is_git_commit")
    return cache.is_git_commit
  endif

  cache.is_git_commit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/COMMIT_EDITMSG$')
  return cache.is_git_commit
enddef

export def IsGitHunkEdit(): bool
  if has_key(cache, "is_git_hunk_edit")
    return cache.is_git_hunk_edit
  endif

  cache.is_git_hunk_edit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/addp-hunk-edit\.diff$')
  return cache.is_git_hunk_edit
enddef

export def IsGitRebase(): bool
  if has_key(cache, "is_git_rebase")
    return cache.is_git_rebase
  endif

  cache.is_git_rebase = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/rebase-merge/git-rebase-todo$')
  return cache.is_git_rebase
enddef

export def IsTabnineAvailable(): bool
  if has_key(cache, "is_tabnine_available")
    return cache.is_tabnine_available
  endif

  if empty($USE_TABNINE)
    const remotes = system("git remote -v 2> /dev/null")
    cache.is_tabnine_available = remotes ==# "" || stringUtil.Includes(remotes, "@github.com:kg8m/")
  else
    cache.is_tabnine_available = $USE_TABNINE ==# "1"
  endif

  return cache.is_tabnine_available
enddef

export def RubygemsPath(): string
  if has_key(cache, "rubygems_path")
    return cache.rubygems_path
  endif

  if exists("$RUBYGEMS_PATH")
    cache.rubygems_path = $RUBYGEMS_PATH
  else
    const command_prefix = (filereadable("./Gemfile") ? "bundle exec ruby" : "ruby -r rubygems")
    const command = $"{command_prefix} -e 'print Gem.path.join(\"\\n\")'"
    const dirpaths = split(system(command), '\n')

    var rubygems_path = ""

    for dirpath in dirpaths
      if isdirectory(dirpath)
        rubygems_path = $"{dirpath}/gems"
        break
      endif
    endfor

    if rubygems_path !=# ""
      cache.rubygems_path = rubygems_path
    else
      throw $"Path to Ruby Gems not found. Candidates: {string(dirpaths)}"
    endif
  endif

  return cache.rubygems_path
enddef

export def RemoteCopy(original_text: string): void
  const text = original_text->substitute('\n$', "", "")
  system("ssh main -t 'LC_CTYPE=UTF-8 pbcopy'", text)

  var message = "Copied"
  const max_width = v:echospace - 60

  if max_width ># 10
    message ..= ": " .. stringUtil.Truncate(text, max_width)->trim()
  endif

  logger.Info(message)
enddef

export def RemoveTrailingWhitespaces()
  const position = getpos(".")
  keeppatterns :'<,'>s/\s\+$//e
  setpos(".", position)
enddef

export def ConvertToVim9script(): void
  if getline(1) !=# "vim9script"
    append(0, ["vim9script", ""])
  endif

  # Replace `function` with `def` and remove `abort`
  :%s/\v^(\s*)function>!?/\1def/Ie
  :%s/\v^(\s*)endfunction>/\1enddef/Ie
  :%s/\v\) abort>/)/Ie

  # Add function’s return type and argument’s type
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
