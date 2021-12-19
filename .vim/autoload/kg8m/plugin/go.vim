vim9script

def kg8m#plugin#go#configure(): void
  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "go",
    hook_source: () => s:on_source(),
  })
enddef

def s:setup_buffer(): void
  setlocal foldmethod=syntax

  nnoremap <buffer> <leader>r :call <SID>run_current()<CR>
enddef

def s:run_current(): void
  write

  const command = printf("go run -race %s", expand("%")->shellescape())
  kg8m#util#terminal#execute_command(command)
enddef

def s:on_source(): void
  g:go_code_completion_enabled = false
  g:go_fmt_autosave            = false
  g:go_doc_keywordprg_enabled  = false
  g:go_def_mapping_enabled     = false
  g:go_gopls_enabled           = false

  g:go_highlight_array_whitespace_error    = true
  g:go_highlight_chan_whitespace_error     = true
  g:go_highlight_extra_types               = true
  g:go_highlight_space_tab_error           = true
  g:go_highlight_trailing_whitespace_error = true
  g:go_highlight_operators                 = true
  g:go_highlight_functions                 = true
  g:go_highlight_function_parameters       = true
  g:go_highlight_function_calls            = true
  g:go_highlight_types                     = true
  g:go_highlight_fields                    = true
  g:go_highlight_build_constraints         = true
  g:go_highlight_generate_tags             = true
  g:go_highlight_string_spellcheck         = true
  g:go_highlight_format_strings            = true
  g:go_highlight_variable_declarations     = true
  g:go_highlight_variable_assignments      = true

  augroup my_vimrc
    autocmd FileType go s:setup_buffer()
  augroup END
enddef
