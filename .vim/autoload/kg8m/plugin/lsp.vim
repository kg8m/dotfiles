vim9script

var s:is_initialized = false

def kg8m#plugin#lsp#configure(): void  # {{{
  kg8m#plugin#lsp#servers#register()

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: kg8m#plugin#lsp#servers#filetypes(),
    hook_source:      function("s:on_source"),
    hook_post_source: function("s:on_post_source"),
  })

  kg8m#plugin#register("mattn/vim-lsp-settings", { if: false, merged: false })
  kg8m#plugin#register("tsuyoshicho/vim-efm-langserver-settings", { if: false, merged: false })
enddef  # }}}

def kg8m#plugin#lsp#is_target_buffer(): bool  # {{{
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
enddef  # }}}

# cf. s:on_lsp_buffer_enabled()
def kg8m#plugin#lsp#is_buffer_enabled(): bool  # {{{
  if has_key(b:, "lsp_buffer_enabled")
    return true
  else
    return s:are_all_servers_running()
  endif
enddef  # }}}

def s:on_lsp_buffer_enabled(): void  # {{{
  if get(b:, "lsp_buffer_enabled", false)
    return
  endif

  if !s:are_all_servers_running()
    return
  endif

  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <Plug>(lsp-next-diagnostic)
  nmap <buffer> ge <Plug>(lsp-next-error)
  nmap <buffer> <S-h> <Plug>(lsp-hover)

  s:overwrite_capabilities()

  if s:is_definition_supported()
    nmap <buffer> g] <Plug>(lsp-definition)
  endif

  augroup my_vimrc  # {{{
    autocmd InsertLeave <buffer> timer_start(100, () => s:document_format({ sync: false }))
    autocmd BufWritePre <buffer> s:document_format({ sync: true })
  augroup END  # }}}

  # cf. kg8m#plugin#lsp#is_buffer_enabled()
  b:lsp_buffer_enabled = true
enddef  # }}}

def s:reset_target_buffer(): void  # {{{
  if has_key(b:, "lsp_target_buffer")
    unlet b:lsp_target_buffer
  endif
enddef  # }}}

def s:are_all_servers_running(): bool  # {{{
  for server_name in lsp#get_allowed_servers()
    if lsp#get_server_status(server_name) !=# "running"
      return false
    endif
  endfor

  return true
enddef  # }}}

# Disable some language servers' document formatting because vim-lsp randomly selects only 1 language server to do
# formatting from language servers which have capability of document formatting. I want to do formatting by
# efm-langserver but vim-lsp sometimes doesn't select it. efm-langserver is always selected if it is the only 1
# language server which has capability of document formatting.
def s:overwrite_capabilities(): void  # {{{
  if &filetype !~# '\v^(go|javascript|ruby|typescript)$'
    return
  endif

  if !s:are_all_servers_running()
    kg8m#util#echo_error_msg("Cannot to overwrite language servers' capabilities because some of them are not running")
    return
  endif

  for server_name in lsp#get_allowed_servers()->filter("v:val !=# 'efm-langserver'")
    var capabilities = lsp#get_server_capabilities(server_name)

    if has_key(capabilities, "documentFormattingProvider")
      capabilities.documentFormattingProvider = false
    endif
  endfor
enddef  # }}}

def s:is_definition_supported(): bool  # {{{
  if !s:are_all_servers_running()
    kg8m#util#echo_error_msg("Cannot to judge whether definition is supported or not because some of them are not running")
    return false
  endif

  for server_name in lsp#get_allowed_servers()
    var capabilities = lsp#get_server_capabilities(server_name)

    if get(capabilities, "definitionProvider", false)
      return true
    endif
  endfor

  return false
enddef  # }}}

def s:document_format(options = {}): void  # {{{
  if get(options, "sync", true)
    silent LspDocumentFormatSync
  else
    if &modified && mode() ==# "n"
      silent LspDocumentFormat
    endif
  endif
enddef  # }}}

def s:on_source(): void  # {{{
  if s:is_initialized
    return
  endif

  g:lsp_diagnostics_enabled          = true
  g:lsp_diagnostics_echo_cursor      = false
  g:lsp_diagnostics_float_cursor     = true
  g:lsp_signs_enabled                = true
  g:lsp_highlight_references_enabled = true
  g:lsp_fold_enabled                 = false
  g:lsp_semantic_enabled             = true

  g:lsp_async_completion = true

  g:lsp_log_verbose = true
  g:lsp_log_file    = expand("~/tmp/vim-lsp.log")

  augroup my_vimrc  # {{{
    autocmd User lsp_setup          kg8m#plugin#lsp#servers#enable()
    autocmd User lsp_setup          kg8m#plugin#lsp#stream#subscribe()
    autocmd User lsp_buffer_enabled s:on_lsp_buffer_enabled()

    autocmd FileType * s:reset_target_buffer()
  augroup END  # }}}

  s:is_initialized = true
enddef  # }}}

def s:on_post_source(): void  # {{{
  # https://github.com/prabirshrestha/vim-lsp/blob/e2a052acce38bd0ae25e57fff734a14a9e2c9ef7/plugin/lsp.vim#L52
  lsp#enable()
enddef  # }}}
