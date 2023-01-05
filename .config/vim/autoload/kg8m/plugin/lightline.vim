vim9script

import autoload "kg8m/plugin/lsp.vim"
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/string.vim" as stringUtil

export def OnSource(): void
  const elements = {
    left: [
      ["mode", "paste"],
      ["warning_filepath"], ["normal_filepath"],
      ["separator"],
      ["filetype"],
      ["warning_fileencoding"], ["normal_fileencoding"],
      ["fileformat"],
      ["separator"],
      ["cursor_position"],
    ],
    right: [
      ["lsp_status"],
    ],
  }

  g:lightline = {
    active: elements,
    inactive: elements,
    component: {
      separator: "|",
      cursor_position: "%l/%L:%v",
    },
    component_function: {
      normal_filepath:     "kg8m#plugin#lightline#NormalFilepath",
      normal_fileencoding: "kg8m#plugin#lightline#NormalFileencoding",
      lsp_status:          "kg8m#plugin#lightline#LspStatus",
    },
    component_expand: {
      warning_filepath:     "kg8m#plugin#lightline#WarningFilepath",
      warning_fileencoding: "kg8m#plugin#lightline#WarningFileencoding",
    },
    component_type: {
      warning_filepath:     "error",
      warning_fileencoding: "error",
    },
    colorscheme: "kg8m",

    # Use same width for all modes to prevent unstable positions.
    # :h g:lightline.mode_map
    mode_map: {
      n:        " NORMAL ",
      i:        " INSERT ",
      R:        "REPLACE ",
      v:        " VISUAL ",
      V:        " V-LINE ",
      "\<C-v>": "V-BLOCK ",
      c:        "COMMAND ",
      s:        " SELECT ",
      S:        " S-LINE ",
      "\<C-s>": "S-BLOCK ",
      t:        "TERMINAL",
    },
  }

  augroup vimrc-plugin-lightline
    autocmd!
    autocmd User after_lsp_buffer_enabled lightline#update()
  augroup END
enddef

export def OnPostSource(): void
  lightline#update()
enddef

export def Filepath(): string
  return (IsReadonly() ? "X " : "")
    .. CurrentFilepath()
    .. (&modified ? " +" : (&modifiable ? "" : " -"))
enddef

export def Fileencoding(): string
  return &fileencoding
enddef

export def NormalFilepath(): string
  return IsIrregularFilepath() ? "" : Filepath()
enddef

export def NormalFileencoding(): string
  return IsIrregularFileencoding() ? "" : Fileencoding()
enddef

export def WarningFilepath(): string
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#IsIrregularFilepath() ? kg8m#plugin#lightline#Filepath() : ''}"
enddef

export def WarningFileencoding(): string
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#IsIrregularFileencoding() ? kg8m#plugin#lightline#Fileencoding() : ''}"
enddef

export def IsIrregularFilepath(): bool
  return IsReadonly() || !!(expand("%") =~# '^suda://')
enddef

export def IsIrregularFileencoding(): bool
  return !empty(&fileencoding) && &fileencoding !=# "utf-8"
enddef

export def LspStatus(): string
  if lsp.IsTargetBuffer()
    if lsp.IsBufferEnabled()
      return LspStatusAfterEnabled()
    else
      return lsp.ICONS.loading
    endif
  else
    return ""
  endif
enddef

def CurrentFilepath(): string
  if &filetype ==# "unite"
    return unite#get_status_string()
  endif

  if &filetype ==# "qf" && has_key(w:, "quickfix_title")
    return w:quickfix_title
  endif

  if fileUtil.CurrentName() ==# ""
    return "[No Name]"
  else
    return TruncateFilepath(fileUtil.CurrentPath())
  endif
enddef

def TruncateFilepath(filepath: string): string
  const max    = winwidth(0) - 50
  const length = len(filepath)

  if length <= max
    return filepath
  else
    # Footer = the last slash and filename
    const footer_width = length - strridx(filepath, "/")
    return stringUtil.Truncate(filepath, max, { footer_width: footer_width })
  endif
enddef

def IsReadonly(): bool
  return &filetype !=# "help" && !!&readonly
enddef

def LspStatusAfterEnabled(): string
  const counts = lsp#get_buffer_diagnostics_counts()
  const types  = ["error", "warning", "information", "hint"]

  const mapped = listUtil.FilterMap(types, (type: string): any => {
    if counts[type] ==# 0
      return false
    else
      return printf("%s %d", lsp.ICONS[type], counts[type])
    endif
  })

  if empty(mapped)
    return lsp.ICONS.ok
  else
    return join(mapped, " ")
  endif
enddef
