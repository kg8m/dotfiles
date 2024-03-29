vim9script

import autoload "kg8m/plugin/fzf_tjump.vim" as fzfTjump
import autoload "kg8m/util/cursor.vim" as cursorUtil
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/filetypes/vim.vim" as vimUtil

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
    fzfTjump.Run()
  endif
enddef

def FallbackForVimAutoloadFunction(): void
  const autoload_funcname = matchstr(expand("<cword>"), '\v^%(\w|#)+$')
  const autoload_prefix   = matchstr(autoload_funcname, '\v^\zs%(\w|#)+\ze#\w+$')

  if empty(autoload_prefix)
    return
  endif

  const autoload_path = printf("%s.vim", autoload_prefix)->substitute('#', "/", "g")
  const filepath = vimUtil.FindAutoloadFile(autoload_path)

  if empty(filepath)
    return
  endif

  const funcname       = matchstr(autoload_funcname, '\v#\zs\w+\ze$')
  const line_pattern   = $'\bexport def {funcname}\('
  const column_pattern = '\v<export def \zs'

  const [line_number, column_number] = fileUtil.DetectLineAndColumnInFile(filepath, line_pattern, column_pattern)
  execute "edit" fnameescape(filepath)
  cursorUtil.MoveIntoFolding(line_number, column_number)
enddef
