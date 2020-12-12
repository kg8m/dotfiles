function kg8m#plugin#go#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:  v:true,
  \   on_ft: "go",
  \   hook_source: function("s:on_source"),
  \ })
endfunction  " }}}

function s:setup_buffer() abort  " {{{
  setlocal foldmethod=syntax

  if kg8m#util#on_tmux()  " {{{
    nnoremap <buffer> <leader>r :write<Cr>:call VimuxRunCommand("go run -race <C-r>%")<Cr>
  else
    nnoremap <buffer> <leader>r :write<Cr>:GoRun -race %<Cr>
  endif  " }}}
endfunction  " }}}

function s:on_source() abort  " {{{
  let g:go_code_completion_enabled = v:false
  let g:go_fmt_autosave            = v:false
  let g:go_doc_keywordprg_enabled  = v:false
  let g:go_def_mapping_enabled     = v:false
  let g:go_gopls_enabled           = v:false

  let g:go_highlight_array_whitespace_error    = v:true
  let g:go_highlight_chan_whitespace_error     = v:true
  let g:go_highlight_extra_types               = v:true
  let g:go_highlight_space_tab_error           = v:true
  let g:go_highlight_trailing_whitespace_error = v:true
  let g:go_highlight_operators                 = v:true
  let g:go_highlight_functions                 = v:true
  let g:go_highlight_function_parameters       = v:true
  let g:go_highlight_function_calls            = v:true
  let g:go_highlight_types                     = v:true
  let g:go_highlight_fields                    = v:true
  let g:go_highlight_build_constraints         = v:true
  let g:go_highlight_generate_tags             = v:true
  let g:go_highlight_string_spellcheck         = v:true
  let g:go_highlight_format_strings            = v:true
  let g:go_highlight_variable_declarations     = v:true
  let g:go_highlight_variable_assignments      = v:true

  augroup my_vimrc  " {{{
    autocmd FileType go call s:setup_buffer()
  augroup END  " }}}
endfunction  " }}}
