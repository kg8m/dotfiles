vim9script

export def Error(message: string, options: dict<bool> = {}): void
  echohl ErrorMsg
  Log("ERROR", message, options)
enddef

export def Warn(message: string, options: dict<bool> = {}): void
  echohl WarningMsg
  Log("WARN", message, options)
enddef

export def Info(message: string, options: dict<bool> = {}): void
  echohl Special
  Log("INFO", message, options)
enddef

export def Debug(message: string, options: dict<bool> = {}): void
  echohl Debug
  Log("DEBUG", message, options)
enddef

def Log(level: string, message: string, options: dict<bool> = {}): void
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
