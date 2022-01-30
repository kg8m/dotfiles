vim9script

def kg8m#util#logger#error(message: string, options: dict<bool> = {}): void
  echohl ErrorMsg
  s:log("ERROR", message, options)
enddef

def kg8m#util#logger#warn(message: string, options: dict<bool> = {}): void
  echohl WarningMsg
  s:log("WARN", message, options)
enddef

def kg8m#util#logger#info(message: string, options: dict<bool> = {}): void
  echohl Special
  s:log("INFO", message, options)
enddef

def kg8m#util#logger#debug(message: string, options: dict<bool> = {}): void
  echohl Debug
  s:log("DEBUG", message, options)
enddef

def s:log(level: string, message: string, options: dict<bool> = {}): void
  try
    const timestamp = strftime("%Y/%m/%d %H:%M:%S")
    const formatted_message = printf("%s %s -- %s", timestamp, level, message)

    if get(options, "save_history", true)
      echomsg message
    else
      echo message
    endif
  finally
    echohl None
  endtry
enddef
