vim9script

def kg8m#plugin#unite#configure(): void
  g:unite_winheight = "100%"

  augroup my_vimrc
    autocmd FileType unite s:setup_buffer()
  augroup END

  kg8m#plugin#configure({
    lazy:   true,
    on_cmd: "Unite",
  })
enddef

def s:setup_buffer(): void
  s:enable_highlighting_cursorline()
  s:disable_default_mappings()
enddef

def s:enable_highlighting_cursorline(): void
  setlocal cursorlineopt=both
enddef

def s:disable_default_mappings(): void
  if !!mapcheck("<S-n>", "n")
    nunmap <buffer> <S-n>
  endif
enddef
