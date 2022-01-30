vim9script

final s:cache = {
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
def kg8m#util#f2#f(): void
  s:prepare("f")
  s:run_singleline()
enddef

# 2-stroke `F` with migemo
def kg8m#util#f2#F(): void
  s:prepare("F")
  s:run_singleline()
enddef

# 2-stroke `t` with migemo
def kg8m#util#f2#t(): void
  s:prepare("t")
  s:run_singleline()
enddef

# 2-stroke `T` with migemo
def kg8m#util#f2#T(): void
  s:prepare("T")
  s:run_singleline()
enddef

# `stargate#ok_vim()` with migemo
def kg8m#util#f2#multiline(): void
  s:prepare("multiline")
  s:run_multiline()
enddef

def kg8m#util#f2#semi(): void
  if empty(s:cache.type)
    feedkeys(";", "n")
  else
    s:repeat()
  endif
enddef

def kg8m#util#f2#comma(): void
  if empty(s:cache.type)
    feedkeys(",", "n")
  else
    s:repeat()
  endif
enddef

def s:repeat(): void
  if s:cache.type ==# "multiline"
    s:run_multiline()
  else
    s:run_singleline()
  endif
enddef

def s:prepare(type: string): void
  s:reset()
  s:cache.type = type
enddef

def s:reset(): void
  s:cache.type    = ""
  s:cache.input   = ""
  s:cache.pattern = ""
enddef

def s:run_singleline(): void
  const forward = s:cache.type =~# '\l'
  const cursor_position = getcurpos()

  const pattern  = s:build_pattern()
  const flags    = (forward ? "" : "b") .. "n"
  const stopline = line(".")

  if s:cache.type ==# "t"
    cursor(cursor_position[1], cursor_position[2] + 1)
  elseif s:cache.type ==# "T"
    cursor(cursor_position[1], cursor_position[2] - 1)
  endif

  const position = searchpos(pattern, flags, stopline)

  if position ==# [0, 0]
    if getcurpos() !=# cursor_position
      cursor(cursor_position[1], cursor_position[2])
    endif

    const message = printf("There are no matches for %s", string(s:cache.input))
    kg8m#util#logger#info(message, { save_history: false })
    s:reset()
  else
    const line_number = position[0]
    var column_number = position[1]

    if s:cache.type ==# "f" && mode(1) =~# '^no'
      column_number += 1
    elseif s:cache.type ==# "t" && mode(1) !~# '^no'
      column_number -= 1
    elseif s:cache.type ==# "T"
      column_number += 1
    endif

    cursor(line_number, column_number)
    s:blink_cursor()
  endif
enddef

def s:run_multiline(): void
  const cursor_position = getcurpos()

  const pattern = s:build_pattern()
  stargate#ok_vim(pattern)

  if getcurpos() !=# cursor_position
    s:blink_cursor()
  endif
enddef

def s:build_pattern(): string
  if !empty(s:cache.pattern)
    return s:cache.pattern
  endif

  const input = getcharstr() .. getcharstr()
  s:cache.input = input

  # Don't check whether multibyte characters are contained in searching text. Always use migemo if available. Because
  # migemo targets are not only multibyte characters. For example, "do" matches with ".". It is too confusing if
  # searching behavior varies depending on multibyte characters existence.
  s:setup_migemo()

  if empty(s:cache.migemo.dictionary_path)
    if !s:cache.migemo.warned
      kg8m#util#logger#warn("migemo isn't available. Check if migemo is executable and its dictionary exists.")
      s:cache.migemo.warned = true
    endif

    s:cache.pattern = s:input_to_smartcase_pattern(input)
  else
    const smartcase_pattern = s:input_to_smartcase_pattern(input)
    const migemo_pattern    = printf(
      "cmigemo -d %s -v -w %s",
      shellescape(s:cache.migemo.dictionary_path),
      shellescape(input)
    )->system()

    s:cache.pattern = printf('\C\%(%s\|%s\)', smartcase_pattern, migemo_pattern)
    g:pattern = s:cache.pattern
  endif

  return s:cache.pattern
enddef

def s:input_to_smartcase_pattern(input: string): string
  return printf(
    '\V%s%s\m',
    input[0] =~# '\l' ? printf('\[%s%s]', input[0], toupper(input[0])) : input[0],
    input[1] =~# '\l' ? printf('\[%s%s]', input[1], toupper(input[1])) : input[1]
  )
enddef

def s:setup_migemo(): void
  if s:cache.migemo.setup_done
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
      const filepath = printf("%s/utf-8/migemo-dict", directory)

      if filereadable(filepath)
        s:cache.migemo.dictionary_path = filepath
        break
      endif
    endfor
  endif

  s:cache.migemo.setup_done = true
enddef

def s:blink_cursor(): void
  if &cursorcolumn
    return
  endif

  setlocal cursorcolumn
  timer_start(200, (_) => {
    setlocal nocursorcolumn
  })
enddef
