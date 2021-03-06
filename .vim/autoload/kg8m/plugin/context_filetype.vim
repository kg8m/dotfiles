vim9script

const s:for_js = [
  { start: '\<html`$', end: '\v^\s*%(//|/?\*)?\s*`', filetype: "html" },
  { start: '\<css`$',  end: '\v^\s*%(//|/?\*)?\s*`', filetype: "css" },
]

def kg8m#plugin#context_filetype#configure(): void
  # For caw.vim and so on
  g:context_filetype#filetypes = {
    javascript: s:for_js,
    typescript: s:for_js,
  }
enddef
