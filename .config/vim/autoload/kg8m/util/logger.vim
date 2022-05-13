vim9script

const HIGHLIGHTS_MAP = {
  ERROR: "ErrorMsg",
  WARN:  "WarningMsg",
  INFO:  "Special",
  DEBUG: "Debug",
}

export def Error(message: string, options: dict<bool> = {}): void
  Log("ERROR", message, options)
enddef

export def Warn(message: string, options: dict<bool> = {}): void
  Log("WARN", message, options)
enddef

export def Info(message: string, options: dict<bool> = {}): void
  Log("INFO", message, options)
enddef

export def Debug(message: string, options: dict<bool> = {}): void
  Log("DEBUG", message, options)
enddef

def Log(level: string, message: string, options: dict<bool> = {}): void
  try
    execute "echohl" HIGHLIGHTS_MAP[level]

    const timestamp = strftime("%Y/%m/%d %H:%M:%S")
    const formatted_message = $"{timestamp} {level} -- {message}"

    if get(options, "save_history", true)
      echomsg message
    else
      echo message
    endif
  finally
    echohl None
  endtry
enddef
