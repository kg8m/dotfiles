vim9script

def kg8m#util#logger#error(message: string): void
  echohl ErrorMsg
  s:log("ERROR", message)
enddef

def kg8m#util#logger#warn(message: string): void
  echohl WarningMsg
  s:log("WARN", message)
enddef

def kg8m#util#logger#info(message: string): void
  echohl Special
  s:log("INFO", message)
enddef

def kg8m#util#logger#debug(message: string): void
  echohl Debug
  s:log("DEBUG", message)
enddef

def s:log(level: string, message: string): void
  try
    const timestamp = strftime("%Y/%m/%d %H:%M:%S")
    const formatted_message = printf("%s %s -- %s", timestamp, level, message)

    echomsg message
  finally
    echohl None
  endtry
enddef
