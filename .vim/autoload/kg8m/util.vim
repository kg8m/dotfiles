vim9script

final s:cache = {}

def kg8m#util#source_local_vimrc(): void
  const filepath = expand("~/.config/vim.local/.vimrc.local")

  if filereadable(filepath)
    execute "source " .. filepath
  endif
enddef

def kg8m#util#on_tmux(): bool
  return !!exists("$TMUX")
enddef

def kg8m#util#on_rails_dir(): bool
  if has_key(s:cache, "on_rails_dir")
    return s:cache.on_rails_dir
  endif

  s:cache.on_rails_dir = isdirectory("./app") && filereadable("./config/environment.rb")
  return s:cache.on_rails_dir
enddef

def kg8m#util#is_ctags_available(): bool
  if has_key(s:cache, "is_ctags_available")
    return s:cache.is_ctags_available
  endif

  s:cache.is_ctags_available = !empty($CTAGS_AVAILABLE)
  return s:cache.is_ctags_available
enddef

def kg8m#util#is_git_tmp_edit(): bool
  return kg8m#util#is_git_commit() || kg8m#util#is_git_hunk_edit() || kg8m#util#is_git_rebase()
enddef

def kg8m#util#is_git_commit(): bool
  if has_key(s:cache, "is_git_commit")
    return s:cache.is_git_commit
  endif

  s:cache.is_git_commit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/COMMIT_EDITMSG$')
  return s:cache.is_git_commit
enddef

def kg8m#util#is_git_hunk_edit(): bool
  if has_key(s:cache, "is_git_hunk_edit")
    return s:cache.is_git_hunk_edit
  endif

  s:cache.is_git_hunk_edit = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/addp-hunk-edit\.diff$')
  return s:cache.is_git_hunk_edit
enddef

def kg8m#util#is_git_rebase(): bool
  if has_key(s:cache, "is_git_rebase")
    return s:cache.is_git_rebase
  endif

  s:cache.is_git_rebase = argc() ==# 1 && !!(argv()[0] =~# '\v\.git%(/.*)?/rebase-merge/git-rebase-todo$')
  return s:cache.is_git_rebase
enddef

def kg8m#util#rubygems_path(): string
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

def kg8m#util#remote_copy(original_text: string): void
  const text = original_text->substitute('\n$', "", "")->shellescape()

  system("printf %s " .. text .. " | ssh main -t 'LC_CTYPE=UTF-8 pbcopy'")

  if &columns > 50
    echomsg "Copied: " .. trim(kg8m#util#string#vital().truncate_skipping(text, &columns - 30, 0, "..."))
  else
    echomsg "Copied"
  endif
enddef

def kg8m#util#remove_trailing_whitespaces()
  const position = getpos(".")
  keeppatterns :'<,'>s/\s\+$//ge
  setpos(".", position)
enddef

def kg8m#util#japanese_matchpairs(): list<list<string>>
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

def kg8m#util#convert_to_vim9script(): void
  if getline(1) !=# "vim9script"
    append(0, ["vim9script", ""])
  endif

  # Replace `function` with `def` and remove `abort`
  :%s/\v^(\s*)function>/\1def/Ie
  :%s/\v^(\s*)endfunction>/\1enddef/Ie
  :%s/\v\) abort>/)/Ie

  # Add function's return type and argument's type
  :%s/\v^(\s*)def ([a-zA-Z&:#_.]+)\((\w+)(.*)\)$/\1def \2(\3: FIXME\4): void/Ie

  # Remove `call` except for:
  #   - :call foo()
  #   - <Cmd>call foo()
  #   - "call foo()"
  #   - 'call foo()'
  :%s/\v(:)@<!(\<Cmd\>)@<!(")@<!(')@<!<call\s+//Ie

  # Replace `let foo .= bar` with `let foo ..= bar`
  :%s/\v<(let\s+)([a-zA-Z&:#_.]+)(\s+)\.\=/\1\2\3..=/Ie

  # Replace `let` with `const` except for:
  #   - :let foo = bar
  :%s/\v(:)@<!<let(\s+)/const\2/Ie

  # Remove function argument's prefix `a:`
  :%s/\v<a:([a-zA-Z_]+)/\1/gIe

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
enddef

def kg8m#util#setup_demo(): void
  set foldcolumn=0
  set signcolumn=no
  lightline#disable()
enddef
