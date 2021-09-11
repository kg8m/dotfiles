vim9script

def kg8m#plugin#lsp#document_format#run_on_save(): void
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

  silent LspDocumentFormatSync
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

  const Mapper    = (_, config) => get(config, "document_format_max_bytes", 9'999'999)
  const max_bytes = configs->mapnew(Mapper)->min()

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
