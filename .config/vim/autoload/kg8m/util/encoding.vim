vim9script

import autoload "kg8m/util.vim"
import autoload "kg8m/util/file.vim" as fileUtil
import autoload "kg8m/util/logger.vim"
import autoload "kg8m/util/string.vim" as stringUtil

export def EditWithGuessedEncoding(options: dict<any> = {}): void
  const filepath = fileUtil.CurrentRelativePath()
  const guessed_encoding = system($"nkf --guess {shellescape(filepath)}")

  if stringUtil.StartsWith(guessed_encoding, "Shift_JIS")
    EditWithCP932(options)
  elseif stringUtil.StartsWith(guessed_encoding, "EUC-JP")
    EditWithEUCJP(options)
  # Support other encodings if needed.
  else
    EditWithUTF8(options)
  endif
enddef

export def EditWithCP932(options: dict<any> = {}): void
  EditWith("cp932", options)
enddef

export def EditWithEUCJP(options: dict<any> = {}): void
  EditWith("euc-jp", options)
enddef

export def EditWithISO2022JP(options: dict<any> = {}): void
  EditWith("iso-2022-jp", options)
enddef

export def EditWithLatin1(options: dict<any> = {}): void
  EditWith("latin1", options)
enddef

export def EditWithShiftJIS(options: dict<any> = {}): void
  EditWith("shift-jis", options)
enddef

export def EditWithUTF8(options: dict<any> = {}): void
  EditWith("utf-8", options)
enddef

def EditWith(encoding: string, options: dict<any> = {}): void
  if get(b:, "encoding_configured", false) && !get(options, "force", false)
    return
  endif

  execute $"edit ++encoding={encoding} +set\\ noreadonly"
  b:encoding_configured = true
enddef
