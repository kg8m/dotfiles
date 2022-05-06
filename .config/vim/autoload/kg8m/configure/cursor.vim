vim9script

final cache = {}

const vertical_line_code      = "\e[6 q"
const vertical_bold_line_code = "\e[2 q"

export def Base(): void
  set backspace=indent,eol,start
  set nostartofline
  set whichwrap=b,s,h,l,<,>,[,],~

  # A comma separated list of these words:
  #   - block:   Allow virtual editing in Visual block mode.
  #   - insert:  Allow virtual editing in Insert mode.
  #   - all:     Allow virtual editing in all modes.
  #   - onemore: Allow the cursor to move just past the end of the line.
  set virtualedit=block
enddef

export def Match(): void
  set showmatch
  set matchtime=1

  const japanese_matchpairs = kg8m#util#JapaneseMatchpairs()->mapnew((_, pair) => join(pair, ":"))->join(",")

  if has_key(cache, "original_matchpairs")
    &matchpairs = cache.original_matchpairs .. "," .. japanese_matchpairs
  else
    cache.original_matchpairs = &matchpairs
    &matchpairs ..= "," .. japanese_matchpairs
  endif
enddef

export def Highlight(): void
  set cursorline
  set cursorlineopt=number

  augroup vimrc-configure-cursor-highlight
    autocmd!
    autocmd FileType qf set cursorlineopt=both
  augroup END
enddef

export def Shape(): void
  if !kg8m#util#string#Includes(&t_SI, vertical_line_code)
    &t_SI ..= vertical_line_code
  endif

  if !kg8m#util#string#Includes(&t_EI, vertical_bold_line_code)
    &t_EI ..= vertical_bold_line_code
  endif
enddef
