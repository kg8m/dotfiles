vim9script

import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/filetypes/vim.vim" as vimUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/string.vim" as stringUtil

export def VimAutoload(): any
  if &filetype !=# "vim"
    return 0
  endif

  var autoload_path = matchstr(getline("."), '\v^\s*import\s+autoload\s+["'']\zs[^"'']+\ze["'']')

  if empty(autoload_path)
    return 0
  endif

  const filepath = vimUtil.FindAutoloadFile(autoload_path)

  if empty(filepath)
    return 0
  else
    return { path: filepath, line: 1, col: 1 }
  endif
enddef

export def RailsFiles(): any
  const routes_result = RailsRoutes()
  if routes_result !=# null
    return routes_result
  endif

  const views_result = RailsViews()
  if views_result !=# null
    return views_result
  endif

  logger.Warn("[kg8m#plugin#gf_user#RailsFiles] File not found")
  return 0
enddef

def RailsRoutes(): any
  const bufname = fileUtil.CurrentRelativePath()

  if bufname ==# "config/routes.rb" || stringUtil.StartsWith(bufname, "config/routes/")
    const route = getline(".")->matchstr('\v<to: ["'']\zs[[:alnum:]_]+#\w+\ze["'']')

    if route !=# ""
      const [controller, action] = split(route, "#")

      const filepath       = $"app/controllers/{controller}_controller.rb"
      const line_pattern   = $'\bdef {action}\b'
      const column_pattern = '\vdef \zs'

      const [line_number, column_number] = fileUtil.DetectLineAndColumnInFile(filepath, line_pattern, column_pattern)

      return { path: filepath, line: line_number, col: column_number }
    endif
  endif

  return null
enddef

def RailsViews(): any
  const filepath = rails#ruby_cfile()
  const filepath_in_search_path = findfile(filepath)

  if !empty(filepath_in_search_path)
    return { path: filepath_in_search_path, line: 1, col: 1 }
  endif

  const view_filepaths = glob($"app/views/{filepath}.*")->split()

  if !empty(view_filepaths)
    for view_filepath in view_filepaths
      if filereadable(view_filepath)
        return { path: view_filepath, line: 1, col: 1 }
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

  return null
enddef
