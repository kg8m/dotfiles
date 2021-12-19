vim9script

def kg8m#plugin#lsp#stream#subscribe(): void
  # Fallback to ctags if definition fails.
  # Depend on vim-fzf-tjump.
  lsp#callbag#pipe(
    lsp#stream(),
    lsp#callbag#filter((x) => s:is_definition_failed_stream(x)),
    lsp#callbag#subscribe({ next: (x) => s:definition_fallback(x) }),
  )
enddef

def s:is_definition_failed_stream(x: dict<any>): bool
  return has_key(x, "request") && get(x.request, "method", "") ==# "textDocument/definition" &&
    has_key(x, "response") && empty(get(x.response, "result", []))
enddef

def s:definition_fallback(x: dict<any>): void
  # Use timer and delay execution because it is too early.
  kg8m#plugin#ensure_sourced("vim-fzf-tjump")
  timer_start(0, (_) => fzf_tjump#jump())
enddef
