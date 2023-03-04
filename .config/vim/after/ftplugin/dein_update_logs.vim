let s:listchars = empty(&l:listchars) ? &listchars : &l:listchars
let s:listchars_items = split(s:listchars, '\v%(\\)@<!,')
call filter(s:listchars_items, "stridx(v:val, 'trail:') ==# -1")
let &l:listchars = join(s:listchars_items, ",")
