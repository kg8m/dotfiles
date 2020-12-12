function kg8m#plugin#fzf#marks#increment() abort  " {{{
  call s:setup()

  let incremental_mark_key = s:detect_key()

  if incremental_mark_key =~# s:incremental_mark_keys_pattern
    echo "Already marked to "..incremental_mark_key
    return
  endif

  if !has_key(s:, "incremental_mark_index")
    let s:incremental_mark_index = 0
  else
    let s:incremental_mark_index = (s:incremental_mark_index + 1) % len(s:incremental_mark_keys)
  endif

  execute "mark "..s:incremental_mark_keys[s:incremental_mark_index]
  echo "Marked to "..s:incremental_mark_keys[s:incremental_mark_index]
endfunction  " }}}

" http://saihoooooooo.hatenablog.com/entry/2013/04/30/001908
function s:setup() abort  " {{{
  if has_key(s:, "incremental_mark_keys")
    return
  endif

  let s:incremental_mark_keys = [
  \   "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  \   "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  \ ]
  let s:incremental_mark_keys_pattern = "^[A-Z]$"

  execute "delmarks "..join(s:incremental_mark_keys, "")
endfunction  " }}}

function s:detect_key() abort  " {{{
  let detected_mark_key   = 0
  let current_filepath    = expand("%")
  let current_line_number = line(".")

  for mark_key in s:incremental_mark_keys
    let position = getpos("'"..mark_key)

    if position[0]
      let filepath    = bufname(position[0])
      let line_number = position[1]

      if filepath ==# current_filepath && line_number ==# current_line_number
        let detected_mark_key = mark_key
        break
      else
        continue
      endif
    endif
  endfor

  return detected_mark_key
endfunction  " }}}
