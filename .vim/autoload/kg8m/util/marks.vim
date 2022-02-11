vim9script

# http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908

const s:incremental_mark_keys = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
]
const s:incremental_mark_keys_pattern = '^[A-Z]$'

var s:incremental_mark_index = -1

execute "delmarks " .. join(s:incremental_mark_keys, "")

export def Increment(): void
  const incremental_mark_key = DetectKey()

  if incremental_mark_key =~# s:incremental_mark_keys_pattern
    printf("Already marked to %s", incremental_mark_key)->kg8m#util#logger#Error()
    return
  endif

  s:incremental_mark_index = (s:incremental_mark_index + 1) % len(s:incremental_mark_keys)

  execute "mark " .. s:incremental_mark_keys[s:incremental_mark_index]
  printf("Marked to %s", s:incremental_mark_keys[s:incremental_mark_index])->kg8m#util#logger#Info()
enddef

def DetectKey(): string
  var detected_mark_key = ""

  const current_filepath    = expand("%")
  const current_line_number = line(".")

  for mark_key in s:incremental_mark_keys
    const position = getpos("'" .. mark_key)

    if position[0] !=# 0
      const filepath    = bufname(position[0])
      const line_number = position[1]

      if filepath ==# current_filepath && line_number ==# current_line_number
        detected_mark_key = mark_key
        break
      else
        continue
      endif
    endif
  endfor

  return detected_mark_key
enddef
