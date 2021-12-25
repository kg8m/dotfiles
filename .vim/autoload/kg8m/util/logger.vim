vim9script

def kg8m#util#logger#error(message: string): void
  echohl ErrorMsg
  echomsg "ERROR -- " .. message
  echohl None
enddef

def kg8m#util#logger#warn(message: string): void
  echohl WarningMsg
  echomsg "WARN -- " .. message
  echohl None
enddef

def kg8m#util#logger#info(message: string): void
  echomsg "INFO -- " .. message
enddef
