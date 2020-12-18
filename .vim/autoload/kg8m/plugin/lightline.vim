vim9script

# Use `final` instead of `const` because this will be overwritten by `kg8m#plugin#lightline#lsp#configure`
final s:elements = {
  left: [
    ["mode", "paste"],
    ["warning_filepath"], ["normal_filepath"],
    ["separator"],
    ["filetype"],
    ["warning_fileencoding"], ["normal_fileencoding"],
    ["fileformat"],
    ["separator"],
    ["lineinfo_with_percent"],
  ],
  right: [
    ["lsp_status"],
  ],
}

var s:lsp_status_buffer_enabled_function: func

def kg8m#plugin#lightline#configure(): void  # {{{
  # http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2

  g:lightline = {
    active: s:elements,
    inactive: s:elements,
    component: {
      separator: "|",
      lineinfo_with_percent: "%l/%L(%p%%) : %v",
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

  if kg8m#plugin#register("tsuyoshicho/lightline-lsp")  # {{{
    kg8m#plugin#lightline#lsp#configure()
    s:lsp_status_buffer_enabled_function = function("kg8m#plugin#lightline#lsp#status")
  else
    s:lsp_status_buffer_enabled_function = function("s:lsp_status_buffer_enabled")
  endif  # }}}
enddef  # }}}

def kg8m#plugin#lightline#elements(): dict<any>  # {{{
  return s:elements
enddef  # }}}

def kg8m#plugin#lightline#filepath(): string  # {{{
  return (s:is_readonly() ? "X " : "")
    .. s:filepath()
    .. (&modified ? " +" : (&modifiable ? "" : " -"))
enddef  # }}}

def kg8m#plugin#lightline#fileencoding(): string  # {{{
  return &fileencoding
enddef  # }}}

def kg8m#plugin#lightline#normal_filepath(): string  # {{{
  return kg8m#plugin#lightline#is_irregular_filepath() ? "" : kg8m#plugin#lightline#filepath()
enddef  # }}}

def kg8m#plugin#lightline#normal_fileencoding(): string  # {{{
  return kg8m#plugin#lightline#is_irregular_fileencoding() ? "" : kg8m#plugin#lightline#fileencoding()
enddef  # }}}

def kg8m#plugin#lightline#warning_filepath(): string  # {{{
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_filepath() ? kg8m#plugin#lightline#filepath() : ''}"
enddef  # }}}

def kg8m#plugin#lightline#warning_fileencoding(): string  # {{{
  # Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_fileencoding() ? kg8m#plugin#lightline#fileencoding() : ''}"
enddef  # }}}

def kg8m#plugin#lightline#is_irregular_filepath(): bool  # {{{
  return s:is_readonly() || !!(expand("%") =~# '^suda://')
enddef  # }}}

def kg8m#plugin#lightline#is_irregular_fileencoding(): bool  # {{{
  return !empty(&fileencoding) && &fileencoding !=# "utf-8"
enddef  # }}}

def kg8m#plugin#lightline#lsp_status(): string  # {{{
  if kg8m#plugin#lsp#is_target_buffer()
    if kg8m#plugin#lsp#is_buffer_enabled()
      return s:lsp_status_buffer_enabled_function()
    else
      return "[LSP] Loading..."
    endif
  else
    return ""
  endif
enddef  # }}}

def s:filepath(): string  # {{{
  if &filetype ==# "unite"
    return unite#get_status_string()
  endif

  if &filetype ==# "qf" && has_key(w:, "quickfix_title")
    return w:quickfix_title
  endif

  const filename = kg8m#util#current_filename()

  if filename ==# ""
    return "[No Name]"
  else
    return winwidth(0) >= 120 ? kg8m#util#current_relative_path() : filename
  endif
enddef  # }}}

def s:is_readonly(): bool  # {{{
  return &filetype !=# "help" && !!&readonly
enddef  # }}}

def s:lsp_status_buffer_enabled(): string  # {{{
  return "[LSP] Active"
enddef  # }}}
