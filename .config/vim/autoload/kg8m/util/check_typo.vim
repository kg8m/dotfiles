vim9script

# http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
export def Setup(): void
  augroup vimrc-util-check_typo
    autocmd!
    autocmd BufWriteCmd *[,*] CheckTypo(expand("<afile>"))
  augroup END
enddef

def CheckTypo(file: string): void
  const writecmd = "write" .. (v:cmdbang ? "!" : "") .. " " .. file
  const prompt = "possible typo: really want to write to '" .. file .. "'? [y/n]: "

  if kg8m#util#input#Confirm(prompt)
    execute writecmd
  endif
enddef
