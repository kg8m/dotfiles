vim9script

def kg8m#plugin#lightline#configure(): void
  kg8m#plugin#configure({
    lazy:     true,
    on_start: true,
    hook_source:      () => s:on_source(),
    hook_post_source: () => s:on_post_source(),
  })
enddef

def kg8m#plugin#lightline#filepath(): string
  return (s:is_readonly() ? "X " : "")
    .. s:current_filepath()
    .. (&modified ? " +" : (&modifiable ? "" : " -"))
enddef

def kg8m#plugin#lightline#fileencoding(): string
  return &fileencoding
enddef

def kg8m#plugin#lightline#normal_filepath(): string
  return kg8m#plugin#lightline#is_irregular_filepath() ? "" : kg8m#plugin#lightline#filepath()
enddef

def kg8m#plugin#lightline#normal_fileencoding(): string
  return kg8m#plugin#lightline#is_irregular_fileencoding() ? "" : kg8m#plugin#lightline#fileencoding()
enddef

def kg8m#plugin#lightline#warning_filepath(): string
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_filepath() ? kg8m#plugin#lightline#filepath() : ''}"
enddef

def kg8m#plugin#lightline#warning_fileencoding(): string
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_fileencoding() ? kg8m#plugin#lightline#fileencoding() : ''}"
enddef

def kg8m#plugin#lightline#is_irregular_filepath(): bool
  return s:is_readonly() || !!(expand("%") =~# '^suda://')
enddef

def kg8m#plugin#lightline#is_irregular_fileencoding(): bool
  return !empty(&fileencoding) && &fileencoding !=# "utf-8"
enddef

def kg8m#plugin#lightline#lsp_status(): string
  if kg8m#plugin#lsp#is_target_buffer()
    if kg8m#plugin#lsp#is_buffer_enabled()
      return s:_lsp_status()
    else
      return g:kg8m#plugin#lsp#icons.loading
    endif
  else
    return ""
  endif
enddef

def s:current_filepath(): string
  if &filetype ==# "unite"
    return unite#get_status_string()
  endif

  if &filetype ==# "qf" && has_key(w:, "quickfix_title")
    return w:quickfix_title
  endif

  if kg8m#util#file#current_name() ==# ""
    return "[No Name]"
  else
    return s:truncate_filepath(kg8m#util#file#current_path())
  endif
enddef

def s:truncate_filepath(filepath: string): string
  const max    = winwidth(0) - 50
  const length = len(filepath)

  if length <= max
    return filepath
  else
    # Footer = the last slash and filename
    const footer_width = length - strridx(filepath, "/")
    const separator    = "..."

    return kg8m#util#string#vital().truncate_skipping(filepath, max, footer_width, separator)
  endif
enddef

def s:is_readonly(): bool
  return &filetype !=# "help" && !!&readonly
enddef

def s:_lsp_status(): string
  const counts = lsp#get_buffer_diagnostics_counts()
  const types  = ["error", "warning", "information", "hint"]

  const mapped = kg8m#util#list#filter_map(types, (type: string): any => {
    if counts[type] ==# 0
      return false
    else
      return printf("%s %d", g:kg8m#plugin#lsp#icons[type], counts[type])
    endif
  })

  if empty(mapped)
    return g:kg8m#plugin#lsp#icons.ok
  else
    return join(mapped, " ")
  endif
enddef

def s:on_source(): void
  # http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2

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
      normal_filepath:     "kg8m#plugin#lightline#normal_filepath",
      normal_fileencoding: "kg8m#plugin#lightline#normal_fileencoding",
      lsp_status:          "kg8m#plugin#lightline#lsp_status",
    },
    component_expand: {
      warning_filepath:     "kg8m#plugin#lightline#warning_filepath",
      warning_fileencoding: "kg8m#plugin#lightline#warning_fileencoding",
    },
    component_type: {
      warning_filepath:     "error",
      warning_fileencoding: "error",
    },
    colorscheme: "kg8m",
  }

  augroup vimrc-plugin-lightline
    autocmd!
    autocmd User after_lsp_buffer_enabled lightline#update()
  augroup END
enddef

def s:on_post_source(): void
  lightline#update()
enddef
