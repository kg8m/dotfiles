vim9script

export def Configure(): void
  gf#user#extend("kg8m#plugin#gf_user#VimAutoload", 1000)
enddef

export def VimAutoload(): any
  if &filetype !=# "vim"
    return 0
  endif

  var autoload_path = matchstr(getline("."), '\v^\s*import\s+autoload\s+["'']\zs[^"'']+\ze["'']')

  if empty(autoload_path)
    return 0
  endif

  const filepath = kg8m#util#filetypes#vim#FindAutoloadFile(autoload_path)

  if empty(filepath)
    return 0
  else
    return { path: filepath, line: 1, col: 1 }
  endif
enddef
