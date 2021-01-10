vim9script

const s:vertical_line_code      = "\e[6 q"
const s:vertical_bold_line_code = "\e[2 q"

def kg8m#configure#cursor#base(): void  # {{{
  set backspace=indent,eol,start
  set nostartofline
  set whichwrap=b,s,h,l,<,>,[,],~

  # A comma separated list of these words:
  #   - block:   Allow virtual editing in Visual block mode.
  #   - insert:  Allow virtual editing in Insert mode.
  #   - all:     Allow virtual editing in all modes.
  #   - onemore: Allow the cursor to move just past the end of the line.
  set virtualedit=block
enddef  # }}}

def kg8m#configure#cursor#match(): void  # {{{
  set showmatch
  set matchtime=1

  const japanese_matchpairs = kg8m#util#japanese_matchpairs()->map((_, pair) => join(pair, ":"))->join(",")
  &matchpairs ..= "," .. japanese_matchpairs
enddef  # }}}

def kg8m#configure#cursor#highlight(): void  # {{{
  set cursorline
  set cursorlineopt=number

  augroup my_vimrc  # {{{
    autocmd FileType qf set cursorlineopt=both
  augroup END  # }}}
enddef  # }}}

def kg8m#configure#cursor#shape(): void  # {{{
  if stridx(&t_SI, s:vertical_line_code) ==# -1
    &t_SI ..= s:vertical_line_code
  endif

  if stridx(&t_EI, s:vertical_bold_line_code) ==# -1
    &t_EI ..= s:vertical_bold_line_code
  endif
enddef  # }}}
