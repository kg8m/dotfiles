vim9script

import autoload "kg8m/plugin/lsp/servers.vim"
import autoload "kg8m/plugin/startify.vim"
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/string.vim" as stringUtil

export const MAX_PRIORITY  = 99
export const HIGH_PRIORITY = 75
export const BASE_PRIORITY = 50
export const MIN_PRIORITY  = 00

const INVALID_REASONS = {
  servers_not_enabled:  "servers aren’t enabled",
  not_allowed:          "automatic formatting isn’t allowed",
  non_target_filepath:  "the filepath isn’t target",
  non_target_buftype:   "the buffer type isn’t target",
  non_target_filetype:  "the filetype isn’t target",
  too_large_filesize:   "the buffer is too large",
  no_server_capability: "servers don’t have capability",
}

final cache = {
  sid: expand("<SID>"),
  timer: -1,
  original_format_next: (..._) => {
    logger.Warn("Overwrite this with original function.")
  },
}

startify.AddToSessionSavevar("b:lsp_document_format_cache")

export def OnInsertLeave(): void
  RequestToTryToRun(200)
enddef

export def OnTextChanged(): void
  RequestToTryToRun(200)
enddef

export def EnforceAutoFormatting(): void
  SetBufferCache("force_formatting", true)
enddef

def RequestToTryToRun(delay: number): void
  timer_stop(cache.timer)
  cache.timer = timer_start(delay, (_) => TryToRun())
enddef

def TryToRun(): void
  if mode() !=# "n"
    autocmd ModeChanged <buffer> ++once RequestToTryToRun(50)
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

  UseBufferCache("count", 0)
  UseBufferCache("changedtick", -1)

  # Disable because organizeImports is sometimes annoying to me.
  # if IsOrganizeImportsAvailable()
  #   if b:changedtick !=# GetBufferCache("changedtick")
  #     TemporarilyDisableOnTextChanged()
  #     LspCodeActionSync source.organizeImports
  #   endif
  # endif

  SetBufferCache("count", GetBufferCache("count") + 1)
  SetBufferCache("changedtick", b:changedtick)

  if GetBufferCache("count") ># 100
    logger.Warn("Abort document formatting because of 100+ times retries.")
    Teardown()
    return
  endif

  # cf. :LspDocumentFormat
  #   - https://github.com/prabirshrestha/vim-lsp/blob/6b7aabde99c409a3c04e1a7d80bbd1b0000c4158/plugin/lsp.vim#L139
  #   - https://github.com/prabirshrestha/vim-lsp/blob/6b7aabde99c409a3c04e1a7d80bbd1b0000c4158/autoload/lsp/internal/document_formatting.vim#L12-L13
  lsp#internal#document_formatting#format({ bufnr: bufnr("%"), server: DetectFormatterServer() })
enddef

def Teardown(): void
  SetBufferCache("count", 0)
enddef

def UseBufferCache(key: string, initial_value: any): void
  if !has_key(b:, "lsp_document_format_cache")
    b:lsp_document_format_cache = {}
  endif

  if !has_key(b:lsp_document_format_cache, key)
    b:lsp_document_format_cache[key] = initial_value
  endif
enddef

def GetBufferCache(key: string, fallback_value: any = null): any
  UseBufferCache(key, fallback_value)
  return b:lsp_document_format_cache[key]
enddef

def SetBufferCache(key: string, value: any): void
  UseBufferCache(key, value)
  b:lsp_document_format_cache[key] = value
enddef

def OriginalFormatNext(x: any): void
  TemporarilyDisableOnTextChanged()
  cache.original_format_next(x)
enddef

# Avoid duplicated or infinitely repeated `LspDocumentFormat`.
def TemporarilyDisableOnTextChanged(): void
  set eventignore=TextChanged
  autocmd SafeState <buffer> ++once set eventignore=
enddef

def ValidateToRun(): dict<any>
  final result = { valid: false, invalid_reason: "" }

  if !AreServersEnabled()
    result.invalid_reason = INVALID_REASONS.servers_not_enabled
    return result
  endif

  if !IsTargetBufferType()
    result.invalid_reason = INVALID_REASONS.non_target_buftype
    return result
  endif

  if !IsTargetFiletype()
    result.invalid_reason = INVALID_REASONS.non_target_filetype
    return result
  endif

  if !IsValidFilesize()
    result.invalid_reason = INVALID_REASONS.too_large_filesize
    return result
  endif

  if !HasServerCapability()
    result.invalid_reason = INVALID_REASONS.no_server_capability
    return result
  endif

  if IsAllowed()
    if !IsTargetFilepath() && !IsForceTargetFilepath()
      result.invalid_reason = INVALID_REASONS.non_target_filepath
      return result
    endif
  else
    if !IsForceTargetFilepath()
      if !GetBufferCache("force_formatting")
        result.invalid_reason = INVALID_REASONS.not_allowed
        return result
      endif
    endif
  endif

  result.valid = true
  return result
enddef

# cf. b:lsp_buffer_enabled
def AreServersEnabled(): bool
  return get(b:, "lsp_buffer_enabled", false)
enddef

# cf. $USE_AUTO_FORMATTING
def IsAllowed(): bool
  return $USE_AUTO_FORMATTING ==# "1"
enddef

def IsTargetFilepath(): bool
  return fileUtil.IsDescendant(expand("%:p")) && !IsIgnoreeFilepath()
enddef

# cf. g:kg8m#plugin#lsp#document_format#ignoree_pattern
def IsIgnoreeFilepath(): bool
  if !has_key(g:, "kg8m#plugin#lsp#document_format#ignoree_pattern")
    return false
  endif

  # Use `getbufinfo()` to get the buffer’s absolute path if it isn’t saved.
  return getbufinfo("%")[0].name =~# g:kg8m#plugin#lsp#document_format#ignoree_pattern
enddef

# cf. g:kg8m#plugin#lsp#document_format#force_target_pattern
def IsForceTargetFilepath(): bool
  if !has_key(g:, "kg8m#plugin#lsp#document_format#force_target_pattern")
    return false
  endif

  # Use `getbufinfo()` to get the buffer’s absolute path if it isn’t saved.
  return getbufinfo("%")[0].name =~# g:kg8m#plugin#lsp#document_format#force_target_pattern
enddef

def IsTargetBufferType(): bool
  return !stringUtil.StartsWith(bufname(), "ginedit://")
enddef

# cf. g:lsp#document_format_ignore_filetypes
def IsTargetFiletype(): bool
  const global_ignore_filetypes = get(g:, "lsp#document_format_ignore_filetypes", [])

  if listUtil.Includes(global_ignore_filetypes, &filetype)
    return false
  endif

  const configs            = servers.Configs(&filetype)
  const ShouldNotBeIgnored = (config) => {
    const ignore_filetypes = get(config, "document_format_ignore_filetypes", [])
    return !listUtil.Includes(ignore_filetypes, &filetype)
  }

  return listUtil.All(configs, ShouldNotBeIgnored)
enddef

def IsValidFilesize(): bool
  const current_byte         = wordcount().bytes
  const configs              = servers.Configs(&filetype)
  const IsSmallerThanMaxByte = (config) => current_byte <= get(config, "document_format_max_byte", 9'999'999)

  return listUtil.All(configs, IsSmallerThanMaxByte)
enddef

def HasServerCapability(): bool
  const configs           = servers.Configs(&filetype)
  const capabilities_list = configs->mapnew((_, config) => lsp#get_server_capabilities(config.name))
  const HasCapability     = (capabilities) => !!get(capabilities, "documentFormattingProvider", false)

  return listUtil.Any(capabilities_list, HasCapability)
enddef

def LogSkipped(invalid_reason: string): void
  if GetBufferCache("skipped_by", "") !=# invalid_reason
    SetBufferCache("skipped_by", invalid_reason)
    logger.Info($"Automatic document formatting is skipped because {invalid_reason}.")
  endif
enddef

def IsOrganizeImportsAvailable(): bool
  const configs     = servers.Configs(&filetype)
  const IsAvailable = (config) => !!get(config, "organize_imports", false)

  return listUtil.Any(configs, IsAvailable)
enddef

def DetectFormatterServer(): string
  final configs = servers.Configs(&filetype)->copy()

  filter(configs, (_, config) => config.activated)
  sort(configs, (lhs, rhs) => {
    return get(rhs, "document_format_priority", BASE_PRIORITY) - get(lhs, "document_format_priority", BASE_PRIORITY)
  })

  return configs[0].name
enddef

# If buffer contents change, don’t apply result of `LspDocumentFormat` but try to retry.
# cf. https://github.com/prabirshrestha/vim-lsp/blob/420143420d929d6bc9e98102b5828e0bbc5c9052/autoload/lsp/internal/document_formatting.vim#L74-L76
def OverwriteFormatNext(): void
  try
    # Call a dummy function which doesn’t exist in order to load target script.
    lsp#internal#document_formatting#dummy()
  catch /^Vim:E117: Unknown function:/
    # Do nothing
  endtry

  const scripts = getscriptinfo({ name: "vim-lsp/autoload/lsp/internal/document_formatting.vim" })

  if empty(scripts)
    logger.Warn("Failed to detect vim-lsp’s document_formatting.vim script.")
  else
    const lsp_document_formatting_sid = scripts[0].sid
    const function_name = $"<SNR>{lsp_document_formatting_sid}_format_next"
    const new_definition_template =<< trim eval VIM
      function {function_name}(x) abort
        let cached_changedtick = {cache.sid}GetBufferCache("changedtick", b:changedtick)

        if b:changedtick ==# cached_changedtick
          call {cache.sid}OriginalFormatNext(a:x)
          call {cache.sid}Teardown()
        else
          call kg8m#util#logger#Info("Retry :LspDocumentFormat because the buffer contents changed.")
          call {cache.sid}TryToRun()
        endif
      endfunction
    VIM
    const new_definition = new_definition_template->join("\n")

    cache.original_format_next = funcref(function_name)

    execute "delfunction" function_name
    execute new_definition
  endif
enddef
OverwriteFormatNext()
