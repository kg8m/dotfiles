vim9script

def kg8m#plugin#lsp#stream#subscribe(): void  # {{{
  # Fallback to ctags if definition fails.
  # Depend on vim-fzf-tjump.
  lsp#callbag#pipe(
    lsp#stream(),
    lsp#callbag#filter(function("s:is_definition_failed_stream")),
    lsp#callbag#subscribe({ next: function("s:definition_fallback") }),
  )
enddef  # }}}

def s:is_definition_failed_stream(x: dict<any>): bool  # {{{
  return has_key(x, "request") && get(x.request, "method", "") ==# "textDocument/definition" &&
    has_key(x, "response") && empty(get(x.response, "result", []))
enddef  # }}}

def s:definition_fallback(x: dict<any>): void  # {{{
  # Use timer and delay execution because it is too early.
  # Manually source vim-fzf-tjump because dein.vim's `on_func` feature is not available.
  # Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
  if !kg8m#plugin#is_sourced("vim-fzf-tjump")
    kg8m#plugin#source("vim-fzf-tjump")
  endif

  timer_start(0, { -> fzf_tjump#jump() })
enddef  # }}}
