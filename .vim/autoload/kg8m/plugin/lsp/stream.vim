vim9script

export def Subscribe(): void
  # Fallback to ctags if definition fails.
  lsp#callbag#pipe(
    lsp#stream(),
    lsp#callbag#filter((x) => IsDefinitionFailedStream(x)),
    lsp#callbag#subscribe({ next: (x) => DefinitionFallback(x) }),
  )
enddef

def IsDefinitionFailedStream(x: dict<any>): bool
  return has_key(x, "request") && get(x.request, "method", "") ==# "textDocument/definition" &&
    has_key(x, "response") && empty(get(x.response, "result", []))
enddef

def DefinitionFallback(x: dict<any>): void
  # Use timer and delay execution because it is too early.
  timer_start(0, (_) => kg8m#plugin#fzf_tjump#Run())
enddef
