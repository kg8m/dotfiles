vim9script

export def EditWithCp932(options: dict<any> = {}): void
  EditWith("cp932", options)
enddef

export def EditWithEucjp(options: dict<any> = {}): void
  EditWith("euc-jp", options)
enddef

export def EditWithIso2022jp(options: dict<any> = {}): void
  EditWith("iso-2022-jp", options)
enddef

export def EditWithLatin1(options: dict<any> = {}): void
  EditWith("latin1", options)
enddef

export def EditWithShiftjis(options: dict<any> = {}): void
  EditWith("shift-jis", options)
enddef

export def EditWithUtf8(options: dict<any> = {}): void
  EditWith("utf-8", options)
enddef

def EditWith(encoding: string, options: dict<any> = {}): void
  if get(b:, "encoding_configured", false) && !get(options, "force", false)
    return
  endif

  execute("edit ++encoding=" .. encoding .. " +set\\ noreadonly")
  b:encoding_configured = true
enddef
