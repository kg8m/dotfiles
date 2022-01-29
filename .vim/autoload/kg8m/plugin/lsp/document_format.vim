vim9script

final s:cache = {
  timer: -1,
  count: 0,
  changedtick: -1,
}

def kg8m#plugin#lsp#document_format#on_save(): void
  s:run({ sync: true })
enddef

def kg8m#plugin#lsp#document_format#on_insert_leave(): void
  s:request_to_run()
enddef

def s:request_to_run(): void
  timer_stop(s:cache.timer)

  if s:cache.count ># 100
    kg8m#util#logger#info("Abort to document format because of 100+ times retry.")
    return
  endif

  s:cache.count += 1
  s:cache.changedtick = b:changedtick
  s:cache.timer = timer_start(200, (_) => s:try_to_run())
enddef

def s:try_to_run(): void
  if b:changedtick !=# s:cache.changedtick
    s:request_to_run()
    return
  endif

  if mode() !=# "n"
    s:request_to_run()
    return
  endif

  s:run()
enddef

def s:teardown(): void
  timer_stop(s:cache.timer)
  s:cache.count = 0
enddef

def s:run(options: dict<bool> = {}): void
  s:teardown()

  if !s:is_allowed()
    s:log_skipped("not_allowed", "Document formatting is skipped because automatic formatting is not allowed.")
    return
  endif

  if !s:is_target_buffer_type()
    s:log_skipped("non_target_buffer_type", "Document formatting is skipped because it isn't target buffer type.")
    return
  endif

  if !s:is_target_filetype()
    s:log_skipped("ignore_filetypes", "Document formatting is skipped because it isn't target filetype.")
    return
  endif

  if !s:is_valid_filesize()
    s:log_skipped(
      "too_large_file",
      "Document formatting is skipped because it is too large. Execute `:LspDocumentFormat` manually."
    )
    return
  endif

  if get(options, "sync", false)
    silent LspDocumentFormatSync
  else
    silent LspDocumentFormat
  endif
enddef

def s:is_allowed(): bool
  return $AUTO_FORMATTING_AVAILABLE ==# "1"
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

def s:log_skipped(type: string, message: string): void
  const var_name = "lsp_document_format_skipped_by_" .. type

  if !has_key(b:, var_name)
    setbufvar(bufnr(), var_name, true)

    # Show after written message.
    timer_start(500, (_) => kg8m#util#logger#info(message))
  endif
enddef
