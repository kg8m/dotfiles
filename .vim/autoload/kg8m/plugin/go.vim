vim9script

def kg8m#plugin#go#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:  v:true,
    on_ft: "go",
    hook_source: function("s:on_source"),
  })
enddef  # }}}

def s:setup_buffer(): void  # {{{
  setlocal foldmethod=syntax

  if kg8m#util#on_tmux()  # {{{
    nnoremap <buffer> <leader>r :write<Cr>:call kg8m#plugin#vimux#run_command("go run -race <C-r>%")<Cr>
  else
    nnoremap <buffer> <leader>r :write<Cr>:GoRun -race %<Cr>
  endif  # }}}
enddef  # }}}

def s:on_source(): void  # {{{
  g:go_code_completion_enabled = v:false
  g:go_fmt_autosave            = v:false
  g:go_doc_keywordprg_enabled  = v:false
  g:go_def_mapping_enabled     = v:false
  g:go_gopls_enabled           = v:false

  g:go_highlight_array_whitespace_error    = v:true
  g:go_highlight_chan_whitespace_error     = v:true
  g:go_highlight_extra_types               = v:true
  g:go_highlight_space_tab_error           = v:true
  g:go_highlight_trailing_whitespace_error = v:true
  g:go_highlight_operators                 = v:true
  g:go_highlight_functions                 = v:true
  g:go_highlight_function_parameters       = v:true
  g:go_highlight_function_calls            = v:true
  g:go_highlight_types                     = v:true
  g:go_highlight_fields                    = v:true
  g:go_highlight_build_constraints         = v:true
  g:go_highlight_generate_tags             = v:true
  g:go_highlight_string_spellcheck         = v:true
  g:go_highlight_format_strings            = v:true
  g:go_highlight_variable_declarations     = v:true
  g:go_highlight_variable_assignments      = v:true

  augroup my_vimrc  # {{{
    autocmd FileType go s:setup_buffer()
  augroup END  # }}}
enddef  # }}}
