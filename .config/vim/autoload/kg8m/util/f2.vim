vim9script

final cache = {
  migemo: {
    setup_done: false,
    dictionary_path: "",
    warned: false,
  },
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
    cursor(cursor_position[1], cursor_position[2] + 1)
  elseif cache.type ==# "T"
    cursor(cursor_position[1], cursor_position[2] - 1)
  endif

  const position = searchpos(pattern, flags, stopline)

  if position ==# [0, 0]
    if getcurpos() !=# cursor_position
      cursor(cursor_position[1], cursor_position[2])
    endif

    const message = $"There are no matches for {string(cache.input)}"
    kg8m#util#logger#Info(message, { save_history: false })
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

    cursor(line_number, column_number)
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
  SetupMigemo()

  if empty(cache.migemo.dictionary_path)
    if !cache.migemo.warned
      kg8m#util#logger#Warn("migemo isn't available. Check if migemo is executable and its dictionary exists.")
      cache.migemo.warned = true
    endif

    cache.pattern = InputToSmartcasePattern(input)
  else
    const smartcase_pattern = InputToSmartcasePattern(input)
    const migemo_pattern    = printf(
      "cmigemo -d %s -v -w %s",
      shellescape(cache.migemo.dictionary_path),
      shellescape(input)
    )->system()

    cache.pattern = $'\C\%({smartcase_pattern}\|{migemo_pattern}\)'
  endif

  return cache.pattern
enddef

def InputToSmartcasePattern(input: string): string
  return printf(
    '\V%s%s\m',
    input[0] =~# '\l' ? printf('\[%s%s]', input[0], toupper(input[0])) : input[0],
    input[1] =~# '\l' ? printf('\[%s%s]', input[1], toupper(input[1])) : input[1]
  )
enddef

def SetupMigemo(): void
  if cache.migemo.setup_done
    return
  endif

  if executable("cmigemo")
    const directories = [
      "/usr/local/share/migemo/",
      "/usr/local/share/cmigemo/",
      "/usr/local/share/",
      "/usr/share/cmigemo/",
      "/usr/share/",
    ]

    for directory in directories
      const filepath = $"{directory}/utf-8/migemo-dict"

      if filereadable(filepath)
        cache.migemo.dictionary_path = filepath
        break
      endif
    endfor
  endif

  cache.migemo.setup_done = true
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
