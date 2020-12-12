let s:vertical_line_code      = "\e[6 q"
let s:vertical_bold_line_code = "\e[2 q"

function kg8m#configure#cursor#base() abort  " {{{
  set backspace=indent,eol,start
  set nostartofline
  set whichwrap=b,s,h,l,<,>,[,],~

  " A comma separated list of these words:
  "   - block:   Allow virtual editing in Visual block mode.
  "   - insert:  Allow virtual editing in Insert mode.
  "   - all:     Allow virtual editing in all modes.
  "   - onemore: Allow the cursor to move just past the end of the line.
  set virtualedit=block
endfunction  " }}}

function kg8m#configure#cursor#match() abort  " {{{
  set showmatch
  set matchtime=1

  " Support Japanese kakkos
  let &matchpairs .= ","..(kg8m#util#japanese_matchpairs()->map("join(v:val, ':')")->join(","))
endfunction  " }}}

function kg8m#configure#cursor#highlight() abort  " {{{
  set cursorline
  set cursorlineopt=number

  augroup my_vimrc  " {{{
    autocmd FileType qf set cursorlineopt=both
  augroup END  " }}}
endfunction  " }}}

function kg8m#configure#cursor#shape() abort  " {{{
  if stridx(&t_SI, s:vertical_line_code) ==# -1
    let &t_SI .= s:vertical_line_code
  endif

  if stridx(&t_EI, s:vertical_bold_line_code) ==# -1
    let &t_EI .= s:vertical_bold_line_code
  endif
endfunction  " }}}
