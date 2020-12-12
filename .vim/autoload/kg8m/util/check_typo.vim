" http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
function kg8m#util#check_typo#setup() abort  " {{{
  augroup my_vimrc  " {{{
    autocmd BufWriteCmd *[,*] call s:check_typo(expand("<afile>"))
  augroup END  " }}}
endfunction  " }}}

function s:check_typo(file) abort  " {{{
  let writecmd = "write"..(v:cmdbang ? "!" : "").." "..a:file

  if a:file =~? "[qfreplace]"
    return
  endif

  let prompt = "possible typo: really want to write to '"..a:file.."'?(y/n):"
  let input = input(prompt)

  if input =~? '^y'
    execute writecmd
  endif
endfunction  " }}}
