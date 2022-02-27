vim9script

export def Subscribe(): void
  # Fallback to ctags or my special logics if definition fails.
  lsp#callbag#pipe(
    lsp#stream(),
    lsp#callbag#filter((x) => IsFailedStream(x)),

    # Use timer and delay execution because it is too early.
    lsp#callbag#subscribe({ next: (_) => timer_start(0, (_) => Fallback()) }),
  )
enddef

def IsFailedStream(x: dict<any>): bool
  return has_key(x, "request") && get(x.request, "method", "") ==# "textDocument/definition" &&
    has_key(x, "response") && empty(get(x.response, "result", []))
enddef

def Fallback(): void
  const original_bufname = bufname()
  const original_cursor_position = getcurpos()

  if &filetype ==# "vim"
    FallbackForVimAutoloadFunction()
  endif

  if bufname() ==# original_bufname && getcurpos() ==# original_cursor_position
    kg8m#plugin#fzf_tjump#Run()
  endif
enddef

def FallbackForVimAutoloadFunction(): void
  const autoload_funcname = matchstr(expand("<cword>"), '\v^%(\w|#)+$')
  const autoload_prefix   = matchstr(autoload_funcname, '\v^\zs%(\w|#)+\ze#\w+$')

  if empty(autoload_prefix)
    return
  endif

  const autoload_path = printf("%s.vim", autoload_prefix)->substitute('#', "/", "g")
  const filepath = kg8m#util#filetypes#vim#FindAutoloadFile(autoload_path)

  if empty(filepath)
    return
  endif

  const funcname = matchstr(autoload_funcname, '\v#\zs\w+\ze$')
  const pattern  = printf('export def %s(', funcname)
  const command  = ["rg", "--fixed-strings", "--line-number", "--no-filename", pattern, filepath]
  const result   = command->mapnew((_, item) => shellescape(item))->join(" ")->system()->trim()

  if !empty(result)
    const line_number   = matchstr(result, '\v\d+')->str2nr()
    const column_number = matchstrpos(result, '\v<export def \zs')[1] - len(line_number)

    execute printf("edit %s", filepath)
    cursor([line_number, column_number])

    # zv: Show cursor even if in fold.
    # zz: Adjust cursor at center of window.
    normal! zvzz
  endif
enddef
