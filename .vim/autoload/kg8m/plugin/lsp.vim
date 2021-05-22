vim9script

def kg8m#plugin#lsp#configure(): void
  kg8m#plugin#lsp#servers#register()

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: kg8m#plugin#lsp#servers#filetypes(),
    hook_source: () => s:on_source(),
  })

  kg8m#plugin#register("mattn/vim-lsp-settings", { if: false, merged: false })
  kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", { if: false, merged: false })
enddef

def kg8m#plugin#lsp#is_target_buffer(): bool
  if !has_key(b:, "lsp_target_buffer")
    b:lsp_target_buffer = false

    for filetype in kg8m#plugin#lsp#servers#filetypes()
      if &filetype ==# filetype
        b:lsp_target_buffer = true
        break
      endif
    endfor
  endif

  return b:lsp_target_buffer
enddef

# cf. s:on_lsp_buffer_enabled()
def kg8m#plugin#lsp#is_buffer_enabled(): bool
  if has_key(b:, "lsp_buffer_enabled")
    return true
  else
    return kg8m#plugin#lsp#servers#are_all_running()
  endif
enddef

def s:on_lsp_buffer_enabled(): void
  if get(b:, "lsp_buffer_enabled", false)
    return
  endif

  if !kg8m#plugin#lsp#servers#are_all_running()
    return
  endif

  # cf. kg8m#plugin#lsp#is_buffer_enabled()
  b:lsp_buffer_enabled = true

  # Lazily set omnifunc to overwrite plugins' configurations.
  s:set_omnifunc()
  timer_start(200, (_) => s:set_omnifunc())

  nmap <buffer> gd <Plug>(lsp-next-diagnostic)
  nmap <buffer> ge <Plug>(lsp-next-error)
  nmap <buffer> <S-h> <Plug>(lsp-hover)

  if s:is_definition_supported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  augroup my_vimrc
    autocmd InsertLeave <buffer> timer_start(100, (_) => s:document_format({ sync: false }))
    autocmd BufWritePre <buffer> s:document_format({ sync: true })
  augroup END

  kg8m#events#notify_after_lsp_buffer_enabled()
enddef

def s:reset_target_buffer(): void
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
enddef

def s:set_omnifunc(): void
  if &omnifunc !=# "lsp#complete" && kg8m#plugin#lsp#is_buffer_enabled()
    setlocal omnifunc=lsp#complete
  endif
enddef

def s:is_definition_supported(): bool
  for server_name in kg8m#plugin#lsp#servers#names(&filetype)
    var capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", false)
      return true
    endif
  endfor

  return false
enddef

def s:document_format(options = {}): void
  if kg8m#util#string#starts_with(bufname(), "gina://")
    return
  endif

  if get(options, "sync", true)
    silent LspDocumentFormatSync
  else
    if &modified && mode() ==# "n"
      silent LspDocumentFormat
    endif
  endif
enddef

def s:on_source(): void
  g:lsp_diagnostics_enabled                        = true
  g:lsp_diagnostics_echo_cursor                    = false
  g:lsp_diagnostics_float_cursor                   = true
  g:lsp_diagnostics_highlights_insert_mode_enabled = false
  g:lsp_signs_enabled                              = true
  g:lsp_highlight_references_enabled               = true
  g:lsp_fold_enabled                               = false
  g:lsp_semantic_enabled                           = true

  g:lsp_async_completion = true

  g:lsp_log_verbose = true
  g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc
    autocmd User lsp_setup          kg8m#plugin#lsp#stream#subscribe()
    autocmd User lsp_buffer_enabled s:on_lsp_buffer_enabled()

    autocmd FileType * s:reset_target_buffer()
  augroup END
enddef
