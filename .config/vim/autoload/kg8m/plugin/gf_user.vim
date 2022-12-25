vim9script

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

export def RailsFiles(): any
  const filepath = rails#ruby_cfile()
  const filepath_in_search_path = findfile(filepath)

  if !empty(filepath_in_search_path)
    return { path: filepath_in_search_path, line: 0, col:  0 }
  endif

  const view_filepaths = glob($"app/views/{filepath}.*")->split()

  if !empty(view_filepaths)
    for view_filepath in view_filepaths
      if filereadable(view_filepath)
        return { path: view_filepath, line: 0, col: 0 }
      endif
    endfor
  endif

  # For `= render "..."` when the cursor is before the `=`
  if &filetype ==# "slim"
    const common_pattern = 'render%(_to_string)?>'

    if search($'\v(\=)@<!\=\s*{common_pattern}', "cn", line(".")) !=# 0
      search($'\v<{common_pattern}', "", line("."))
      return RailsFiles()
    endif
  endif

  kg8m#util#logger#Warn($"[kg8m#plugin#gf_user#RailsFiles] File not found: {string(filepath)}")
  return 0
enddef
