vim9script

def kg8m#util#encoding#edit_with_cp932(options: dict<any> = {}): void
  s:edit_with("cp932", options)
enddef

def kg8m#util#encoding#edit_with_eucjp(options: dict<any> = {}): void
  s:edit_with("euc-jp", options)
enddef

def kg8m#util#encoding#edit_with_iso2022jp(options: dict<any> = {}): void
  s:edit_with("iso-2022-jp", options)
enddef

def kg8m#util#encoding#edit_with_latin1(options: dict<any> = {}): void
  s:edit_with("latin1", options)
enddef

def kg8m#util#encoding#edit_with_shiftjis(options: dict<any> = {}): void
  s:edit_with("shift-jis", options)
enddef

def kg8m#util#encoding#edit_with_utf8(options: dict<any> = {}): void
  s:edit_with("utf-8", options)
enddef

def s:edit_with(encoding: string, options: dict<any> = {}): void
  if get(b:, "encoding_configured", false) && !get(options, "force", false)
    return
  endif

  execute("edit ++encoding=" .. encoding .. " +set\\ noreadonly")
  b:encoding_configured = true
enddef
