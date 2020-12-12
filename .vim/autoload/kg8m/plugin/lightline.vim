let s:elements = #{
\   left: [
\     ["mode", "paste"],
\     ["warning_filepath"], ["normal_filepath"],
\     ["separator"],
\     ["filetype"],
\     ["warning_fileencoding"], ["normal_fileencoding"],
\     ["fileformat"],
\     ["separator"],
\     ["lineinfo_with_percent"],
\     ["search_count"],
\   ],
\   right: [
\     ["lsp_status"],
\   ],
\ }

function kg8m#plugin#lightline#configure() abort  " {{{
  " http://d.hatena.ne.jp/itchyny/20130828/1377653592
  set laststatus=2

  let g:lightline = #{
  \   active: s:elements,
  \   inactive: s:elements,
  \   component: #{
  \     separator: "|",
  \     lineinfo_with_percent: "%l/%L(%p%%) : %v",
  \   },
  \   component_function: #{
  \     normal_filepath:     "kg8m#plugin#lightline#normal_filepath",
  \     normal_fileencoding: "kg8m#plugin#lightline#normal_fileencoding",
  \     lsp_status:          "kg8m#plugin#lightline#lsp_status",
  \   },
  \   component_expand: #{
  \     warning_filepath:     "kg8m#plugin#lightline#warning_filepath",
  \     warning_fileencoding: "kg8m#plugin#lightline#warning_fileencoding",
  \     search_count:         "kg8m#plugin#lightline#search_count",
  \   },
  \   component_type: #{
  \     warning_filepath:     "error",
  \     warning_fileencoding: "error",
  \   },
  \   colorscheme: "kg8m",
  \ }

  if kg8m#plugin#register("tsuyoshicho/lightline-lsp")  " {{{
    call kg8m#plugin#lightline#lsp#configure()
    let s:lsp_status_buffer_enabled_function = function("kg8m#plugin#lightline#lsp#status")
  else
    let s:lsp_status_buffer_enabled_function = function("s:lsp_status_buffer_enabled")
  endif  " }}}
endfunction  " }}}

function kg8m#plugin#lightline#elements() abort  " {{{
  return s:elements
endfunction  " }}}

function kg8m#plugin#lightline#filepath() abort  " {{{
  return (s:is_readonly() ? "X " : "")
  \   ..s:filepath()
  \   ..(&modified ? " +" : (&modifiable ? "" : " -"))
endfunction  " }}}

function kg8m#plugin#lightline#fileencoding() abort  " {{{
  return &fileencoding
endfunction  " }}}

function kg8m#plugin#lightline#normal_filepath() abort  " {{{
  return kg8m#plugin#lightline#is_irregular_filepath() ? "" : kg8m#plugin#lightline#filepath()
endfunction  " }}}

function kg8m#plugin#lightline#normal_fileencoding() abort  " {{{
  return kg8m#plugin#lightline#is_irregular_fileencoding() ? "" : kg8m#plugin#lightline#fileencoding()
endfunction  " }}}

function kg8m#plugin#lightline#warning_filepath() abort  " {{{
  " Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_filepath() ? kg8m#plugin#lightline#filepath() : ''}"
endfunction  " }}}

function kg8m#plugin#lightline#warning_fileencoding() abort  " {{{
  " Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{kg8m#plugin#lightline#is_irregular_fileencoding() ? kg8m#plugin#lightline#fileencoding() : ''}"
endfunction  " }}}

function kg8m#plugin#lightline#is_irregular_filepath() abort  " {{{
  " `sudo:` prefix for sudo.vim, which I used to use
  return s:is_readonly() || expand("%") =~# '\v^(sudo:|suda://)'
endfunction  " }}}

function kg8m#plugin#lightline#is_irregular_fileencoding() abort  " {{{
  return !empty(&fileencoding) && &fileencoding !=# "utf-8"
endfunction  " }}}

function kg8m#plugin#lightline#search_count() abort  " {{{
  " Use `%{...}` because component-expansion result is shared with other windows/buffers
  return "%{v:hlsearch ? kg8m#plugin#lightline#search_count_if_searching() : ''}"
endfunction  " }}}

function kg8m#plugin#lightline#search_count_if_searching() abort  " {{{
  let counts = searchcount()

  " 0: search was fully completed
  if counts.incomplete ==# 0
    let current = counts.current
    let total   = counts.total
  else
    let current = counts.current <# counts.maxcount ? counts.current : "?"
    let total   = counts.maxcount.."+"
  endif

  return "["..current.."/"..total.."]"
endfunction  " }}}

function kg8m#plugin#lightline#lsp_status() abort  " {{{
  if kg8m#plugin#lsp#is_target_buffer()
    if kg8m#plugin#lsp#is_buffer_enabled()
      return s:lsp_status_buffer_enabled_function()
    else
      return "[LSP] Loading..."
    endif
  else
    return ""
  endif
endfunction  " }}}

function s:filepath() abort  " {{{
  if &filetype ==# "unite"
    return unite#get_status_string()
  endif

  if &filetype ==# "qf" && has_key(w:, "quickfix_title")
    return w:quickfix_title
  endif

  let filename = kg8m#util#current_filename()

  if filename ==# ""
    return "[No Name]"
  else
    return winwidth(0) >= 120 ? kg8m#util#current_relative_path() : filename
  endif
endfunction  " }}}

function s:is_readonly() abort  " {{{
  return &filetype !=# "help" && &readonly
endfunction  " }}}

function s:lsp_status_buffer_enabled() abort  " {{{
  return "[LSP] Active"
endfunction  " }}}
