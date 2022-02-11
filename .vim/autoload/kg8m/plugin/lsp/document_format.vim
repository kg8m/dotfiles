vim9script

final s:cache = {
  sid: expand("<SID>"),
  timer: -1,
  original_format_next: (..._) => {
    kg8m#util#logger#Warn("Overwrite this with original function.")
  },
}

export def OnInsertLeave(): void
  LazyRun(200)
enddef

export def OnTextChanged(): void
  LazyRun(200)
enddef

def LazyRun(delay: number): void
  timer_stop(s:cache.timer)
  s:cache.timer = timer_start(delay, (_) => TryToRun())
enddef

def TryToRun(): void
  if mode() !=# "n"
    autocmd ModeChanged <buffer> ++once LazyRun(50)
    return
  endif

  Run()
enddef

def Run(): void
  const validity = ValidateToRun()

  if !validity.valid
    LogSkipped(validity.invalid_reason)
    return
  endif

  UseCache("count", 0)
  UseCache("changedtick", -1)

  if IsOrganizeImportsAvailable()
    if b:changedtick !=# b:lsp_document_format_cache.changedtick
      TemporarilyDisableOnTextChanged()
      LspCodeActionSync source.organizeImports
    endif
  endif

  b:lsp_document_format_cache.count += 1
  b:lsp_document_format_cache.changedtick = b:changedtick

  if b:lsp_document_format_cache.count ># 100
    kg8m#util#logger#Warn("Abort document formatting because of 100+ times retries.")
    Teardown()
    return
  endif

  LspDocumentFormat
enddef

def Teardown(): void
  b:lsp_document_format_cache.count = 0
enddef

def UseCache(key: string, initial_value: any): void
  if !has_key(b:, "lsp_document_format_cache")
    b:lsp_document_format_cache = {}
  endif

  if !has_key(b:lsp_document_format_cache, key)
    b:lsp_document_format_cache[key] = initial_value
  endif
enddef

def OriginalFormatNext(x: any): void
  TemporarilyDisableOnTextChanged()
  s:cache.original_format_next(x)
enddef

# Avoid duplicated or infinitely repeated `LspDocumentFormat`.
def TemporarilyDisableOnTextChanged(): void
  set eventignore=TextChanged
  autocmd SafeState <buffer> ++once set eventignore=
enddef

def ValidateToRun(): dict<any>
  final result = { valid: false, invalid_reason: "" }

  if !AreServersEnabled()
    result.invalid_reason = "non-enabled server"
    return result
  endif

  if IsAllowed()
    if !IsTargetFilepath() && !IsForceTargetFilepath()
      result.invalid_reason = "non target filepath"
      return result
    endif
  else
    if !IsForceTargetFilepath()
      result.invalid_reason = "not allowed automatic formatting"
      return result
    endif
  endif

  if !IsTargetBufferType()
    result.invalid_reason = "non target buffer type"
    return result
  endif

  if !IsTargetFiletype()
    result.invalid_reason = "non target filetype"
    return result
  endif

  if !IsValidFilesize()
    result.invalid_reason = "too large filesize"
    return result
  endif

  if !HasServerCapability()
    result.invalid_reason = "no server capability"
    return result
  endif

  result.valid = true
  return result
enddef

def AreServersEnabled(): bool
  return get(b:, "lsp_buffer_enabled", false)
enddef

def IsAllowed(): bool
  return $AUTO_FORMATTING_AVAILABLE ==# "1"
enddef

def IsTargetFilepath(): bool
  return kg8m#util#file#IsDescendant(expand("%:p"))
enddef

def IsForceTargetFilepath(): bool
  if !has_key(g:, "kg8m#plugin#lsp#document_format#force_target_pattern")
    return false
  endif

  return expand("%:p") =~# g:kg8m#plugin#lsp#document_format#force_target_pattern
enddef

def IsTargetBufferType(): bool
  return !kg8m#util#string#StartsWith(bufname(), "gina://")
enddef

def IsTargetFiletype(): bool
  const configs            = kg8m#plugin#lsp#servers#Configs(&filetype)
  const ShouldNotBeIgnored = (config) => {
    const ignore_filetypes = get(config, "document_format_ignore_filetypes", [])
    return !kg8m#util#list#Includes(ignore_filetypes, &filetype)
  }

  return kg8m#util#list#All(configs, ShouldNotBeIgnored)
enddef

def IsValidFilesize(): bool
  const current_byte         = wordcount().bytes
  const configs              = kg8m#plugin#lsp#servers#Configs(&filetype)
  const IsSmallerThanMaxByte = (config) => current_byte <= get(config, "document_format_max_byte", 9'999'999)

  return kg8m#util#list#All(configs, IsSmallerThanMaxByte)
enddef

def HasServerCapability(): bool
  const configs           = kg8m#plugin#lsp#servers#Configs(&filetype)
  const capabilities_list = configs->mapnew((_, config) => lsp#get_server_capabilities(config.name))
  const HasCapability     = (capabilities) => !!get(capabilities, "documentFormattingProvider", false)

  return kg8m#util#list#Any(capabilities_list, HasCapability)
enddef

def LogSkipped(invalid_reason: string): void
  UseCache("skipped_by", "")

  if b:lsp_document_format_cache.skipped_by !=# invalid_reason
    b:lsp_document_format_cache.skipped_by = invalid_reason

    const message = printf("Automatic document formatting is skipped due to %s.", invalid_reason)
    kg8m#util#logger#Info(message)
  endif
enddef

def IsOrganizeImportsAvailable(): bool
  const configs     = kg8m#plugin#lsp#servers#Configs(&filetype)
  const IsAvailable = (config) => !!get(config, "organize_imports", false)

  return kg8m#util#list#Any(configs, IsAvailable)
enddef

# If buffer contents change, don't apply result of `LspDocumentFormat` but try to retry.
# cf. https://github.com/prabirshrestha/vim-lsp/blob/420143420d929d6bc9e98102b5828e0bbc5c9052/autoload/lsp/internal/document_formatting.vim#L74-L76
def Overwrite(): void
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
    kg8m#util#logger#Warn("Failed to detect vim-lsp's document_formatting script.")
  else
    const function_name = "<SNR>" .. lsp_document_formatting_sid .. "_format_next"
    const new_definition_template =<< trim VIM
      function {{ function_name }}(x) abort
        if b:changedtick ==# b:lsp_document_format_cache.changedtick
          call {{ SID }}OriginalFormatNext(a:x)
          call {{ SID }}Teardown()
        else
          call kg8m#util#logger#Info("Retry :LspDocumentFormat because the buffer contents changed.")
          call {{ SID }}TryToRun()
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
Overwrite()
