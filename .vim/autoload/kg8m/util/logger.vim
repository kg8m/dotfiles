vim9script

def kg8m#util#logger#error(message: string): void  # {{{
  echohl ErrorMsg
  echomsg message
  echohl None
enddef  # }}}

def kg8m#util#logger#warn(message: string): void  # {{{
  echohl WarningMsg
  echomsg message
  echohl None
enddef  # }}}
