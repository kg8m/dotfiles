vim9script

const s:filetypes = {
  for_js: [
    { start: '\<html`$', end: '^\s*`', filetype: 'html' },
    { start: '\<css`$', end: '^\s*`', filetype: 'css' },
  ],
}

def kg8m#plugin#context_filetype#configure(): void  # {{{
  # For caw.vim and so on
  g:context_filetype#filetypes = {
    javascript: s:filetypes.for_js,
    typescript: s:filetypes.for_js,
  }
enddef  # }}}
