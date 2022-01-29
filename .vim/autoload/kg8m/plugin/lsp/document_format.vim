vim9script

final s:cache = {
  sid: expand("<SID>"),
  timer: -1,
  original_format_next: (..._) => {
    kg8m#util#logger#warn("Overwrite this with original function.")
  },
}

def kg8m#plugin#lsp#document_format#on_insert_leave(): void
  s:lazy_run(200)
enddef

def kg8m#plugin#lsp#document_format#on_text_changed(): void
  s:lazy_run(200)
enddef

def s:lazy_run(delay: number): void
  timer_stop(s:cache.timer)
  s:cache.timer = timer_start(delay, (_) => s:try_to_run())
enddef

def s:try_to_run(): void
  if mode() !=# "n"
    autocmd ModeChanged <buffer> ++once s:lazy_run(50)
    return
  endif

  s:run()
enddef

def s:run(): void
  const validity = s:validate_to_run()

  if !validity.valid
    s:log_skipped(validity.invalid_reason)
    return
  endif

  s:use_cache("count", 0)
  s:use_cache("changedtick", -1)

  if s:is_organize_imports_available()
    if b:changedtick !=# b:lsp_document_format_cache.changedtick
      s:temporarily_disable_on_text_changed()
      LspCodeActionSync source.organizeImports
    endif
  endif

  b:lsp_document_format_cache.count += 1
  b:lsp_document_format_cache.changedtick = b:changedtick

  if b:lsp_document_format_cache.count ># 100
    kg8m#util#logger#warn("Abort document formatting because of 100+ times retries.")
    s:teardown()
    return
  endif

  LspDocumentFormat
enddef

def s:teardown(): void
  b:lsp_document_format_cache.count = 0
enddef

def s:use_cache(key: string, initial_value: any): void
  if !has_key(b:, "lsp_document_format_cache")
    b:lsp_document_format_cache = {}
  endif

  if !has_key(b:lsp_document_format_cache, key)
    b:lsp_document_format_cache[key] = initial_value
  endif
enddef

def s:original_format_next(x: any): void
  s:temporarily_disable_on_text_changed()
  s:cache.original_format_next(x)
enddef

# Avoid duplicated or infinitely repeated `LspDocumentFormat`.
def s:temporarily_disable_on_text_changed(): void
  set eventignore=TextChanged
  autocmd SafeState <buffer> ++once set eventignore=
enddef

def s:validate_to_run(): dict<any>
  final result = { valid: false, invalid_reason: "" }

  if !s:are_servers_enabled()
    result.invalid_reason = "non-enabled server"
    return result
  endif

  if s:is_allowed()
    if !s:is_target_filepath() && !s:is_force_target_filepath()
      result.invalid_reason = "non target filepath"
      return result
    endif
  else
    if !s:is_force_target_filepath()
      result.invalid_reason = "not allowed automatic formatting"
      return result
    endif
  endif

  if !s:is_target_buffer_type()
    result.invalid_reason = "non target buffer type"
    return result
  endif

  if !s:is_target_filetype()
    result.invalid_reason = "non target filetype"
    return result
  endif

  if !s:is_valid_filesize()
    result.invalid_reason = "too large filesize"
    return result
  endif

  if !s:has_server_capability()
    result.invalid_reason = "no server capability"
    return result
  endif

  result.valid = true
  return result
enddef

def s:are_servers_enabled(): bool
  return get(b:, "lsp_buffer_enabled", false)
enddef

def s:is_allowed(): bool
  return $AUTO_FORMATTING_AVAILABLE ==# "1"
enddef

def s:is_target_filepath(): bool
  return kg8m#util#file#is_descendant(expand("%:p"))
enddef

def s:is_force_target_filepath(): bool
  if !has_key(g:, "kg8m#plugin#lsp#document_format#force_target_pattern")
    return false
  endif

  return expand("%:p") =~# g:kg8m#plugin#lsp#document_format#force_target_pattern
enddef

def s:is_target_buffer_type(): bool
  return !kg8m#util#string#starts_with(bufname(), "gina://")
enddef

def s:is_target_filetype(): bool
  const configs = kg8m#plugin#lsp#servers#configs(&filetype)

  const Mapper           = (_, config) => get(config, "document_format_ignore_filetypes", [])
  const ignore_filetypes = configs->mapnew(Mapper)->flattennew()

  return !kg8m#util#list#includes(ignore_filetypes, &filetype)
enddef

def s:is_valid_filesize(): bool
  const configs = kg8m#plugin#lsp#servers#configs(&filetype)

  const Mapper   = (_, config) => get(config, "document_format_max_byte", 9'999'999)
  const max_byte = configs->mapnew(Mapper)->min()

  return wordcount().bytes <= max_byte
enddef

def s:has_server_capability(): bool
  const configs           = kg8m#plugin#lsp#servers#configs(&filetype)
  const capabilities_list = configs->mapnew((_, config) => lsp#get_server_capabilities(config.name))
  const HasCapability     = (capabilities) => !!get(capabilities, "documentFormattingProvider", false)

  return kg8m#util#list#any(capabilities_list, HasCapability)
enddef

def s:log_skipped(invalid_reason: string): void
  s:use_cache("skipped_by", "")

  if b:lsp_document_format_cache.skipped_by !=# invalid_reason
    b:lsp_document_format_cache.skipped_by = invalid_reason

    const message = printf("Automatic document formatting is skipped due to %s.", invalid_reason)
    kg8m#util#logger#info(message)
  endif
enddef

def s:is_organize_imports_available(): bool
  const configs     = kg8m#plugin#lsp#servers#configs(&filetype)
  const IsAvailable = (config) => !!get(config, "organize_imports", false)

  return kg8m#util#list#any(configs, IsAvailable)
enddef

# If buffer contents change, don't apply result of `LspDocumentFormat` but try to retry.
# cf. https://github.com/prabirshrestha/vim-lsp/blob/420143420d929d6bc9e98102b5828e0bbc5c9052/autoload/lsp/internal/document_formatting.vim#L74-L76
def s:overwrite(): void
  try
    # Call a dummy function which doesn't exist in order to load target script.
    lsp#internal#document_formatting#dummy()
  catch /^Vim:E117: Unknown function:/
    # Do nothing
  endtry

  var lsp_document_formatting_sid = ""

  for scriptname in split(execute("scriptnames"), "\n")
    if scriptname =~# 'vim-lsp/autoload/lsp/internal/document_formatting\.vim'
      lsp_document_formatting_sid = matchstr(scriptname, '\v^ *(\d+)')
      break
    endif
  endfor

  if empty(lsp_document_formatting_sid)
    kg8m#util#logger#warn("Failed to detect vim-lsp's document_formatting script.")
  else
    const function_name = "<SNR>" .. lsp_document_formatting_sid .. "_format_next"
    const new_definition_template =<< trim VIM
      function {{ function_name }}(x) abort
        if b:changedtick ==# b:lsp_document_format_cache.changedtick
          call {{ SID }}original_format_next(a:x)
          call {{ SID }}teardown()
        else
          call kg8m#util#logger#info("Retry :LspDocumentFormat because the buffer contents changed.")
          call {{ SID }}try_to_run()
        endif
      endfunction
    VIM
    const new_definition =
      new_definition_template->join("\n")
        ->substitute('{{ function_name }}', function_name, "")
        ->substitute('{{ SID }}', s:cache.sid, "g")

    s:cache.original_format_next = funcref(function_name)

    execute("delfunction " .. function_name)
    execute(new_definition)
  endif
enddef
s:overwrite()
