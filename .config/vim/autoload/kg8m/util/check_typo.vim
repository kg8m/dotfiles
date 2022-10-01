vim9script

# http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
export def Setup(): void
  augroup vimrc-util-check_typo
    autocmd!
    autocmd BufWriteCmd *[,*] CheckTypo(expand("<afile>"))
  augroup END
enddef

def CheckTypo(filepath: string): void
  const prompt = $"possible typo: really want to write to `{filepath}`?"

  if kg8m#util#input#Confirm(prompt)
    const write_command = v:cmdbang ? "write!" : "write"
    execute write_command fnameescape(filepath)
  endif
enddef
