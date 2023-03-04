vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/cursor.vim" as cursorUtil
import autoload "kg8m/util/logger.vim"

final cache = {
  type: "",
  input: "",
  pattern: "",
}

# 2-stroke `f` with migemo
export def LowerF(): void
  Prepare("f")
  RunSingleline()
enddef

# 2-stroke `F` with migemo
export def UpperF(): void
  Prepare("F")
  RunSingleline()
enddef

# 2-stroke `t` with migemo
export def LowerT(): void
  Prepare("t")
  RunSingleline()
enddef

# 2-stroke `T` with migemo
export def UpperT(): void
  Prepare("T")
  RunSingleline()
enddef

# `stargate#OKvim()` with migemo
export def Multiline(): void
  Prepare("multiline")
  RunMultiline()
enddef

export def Semi(): void
  if empty(cache.type)
    feedkeys(";", "n")
  else
    Repeat()
  endif
enddef

export def Comma(): void
  if empty(cache.type)
    feedkeys(",", "n")
  else
    Repeat()
  endif
enddef

def Repeat(): void
  if cache.type ==# "multiline"
    RunMultiline()
  else
    RunSingleline()
  endif
enddef

def Prepare(type: string): void
  Reset()
  cache.type = type
enddef

def Reset(): void
  cache.type    = ""
  cache.input   = ""
  cache.pattern = ""
enddef

def RunSingleline(): void
  const forward = cache.type =~# '\l'
  const cursor_position = getcurpos()

  const pattern  = BuildPattern()
  const flags    = (forward ? "" : "b") .. "n"
  const stopline = line(".")

  if cache.type ==# "t"
    cursorUtil.Move(cursor_position[1], cursor_position[2] + 1)
  elseif cache.type ==# "T"
    cursorUtil.Move(cursor_position[1], cursor_position[2] - 1)
  endif

  const position = searchpos(pattern, flags, stopline)

  if position ==# [0, 0]
    if getcurpos() !=# cursor_position
      cursorUtil.Move(cursor_position[1], cursor_position[2])
    endif

    const message = $"There are no matches for {string(cache.input)}"
    logger.Info(message, { save_history: false })
    Reset()
  else
    const line_number = position[0]
    var column_number = position[1]

    if cache.type ==# "f" && mode(1) =~# '^no'
      column_number += 1
    elseif cache.type ==# "t" && mode(1) !~# '^no'
      column_number -= 1
    elseif cache.type ==# "T"
      column_number += 1
    endif

    cursorUtil.Move(line_number, column_number)
    BlinkCursor()
  endif
enddef

def RunMultiline(): void
  const cursor_position = getcurpos()

  const pattern = BuildPattern()
  stargate#OKvim(pattern)

  if getcurpos() !=# cursor_position
    BlinkCursor()
  endif
enddef

def BuildPattern(): string
  if !empty(cache.pattern)
    return cache.pattern
  endif

  const input = getcharstr() .. getcharstr()
  cache.input = input

  # Don't check whether multibyte characters are contained in searching text. Always use migemo if available. Because
  # migemo targets are not only multibyte characters. For example, "do" matches with ".". It is too confusing if
  # searching behavior varies depending on multibyte characters existence.

  const smartcase_pattern = InputToSmartcasePattern(input)
  const migemo_pattern = kensaku#query(input)->escape("~")

  cache.pattern = $'\C\%({smartcase_pattern}\|{migemo_pattern}\)'

  return cache.pattern
enddef

def InputToSmartcasePattern(original_full_input: string): string
  const input1 = escape(original_full_input[0], "\\")
  const input2 = escape(original_full_input[1], "\\")
  const BuildFullPattern = (pattern1: string, pattern2: string) => printf('\V%s%s\m', pattern1, pattern2)

  if original_full_input =~# '\u'
    return BuildFullPattern(input1, input2)
  else
    const BuildCaseInsensitivePattern =
      (input: string) => input =~# '\l' ? printf('\[%s%s]', input, toupper(input)) : input

    return BuildFullPattern(
      BuildCaseInsensitivePattern(input1),
      BuildCaseInsensitivePattern(input2)
    )
  endif
enddef

def BlinkCursor(): void
  if &cursorcolumn
    return
  endif

  setlocal cursorcolumn
  timer_start(200, (_) => {
    setlocal nocursorcolumn
  })
enddef

plugin.EnsureSourced("kensaku.vim")
