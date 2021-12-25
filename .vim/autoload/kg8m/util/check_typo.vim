vim9script

# http://d.hatena.ne.jp/tyru/touch/20130419/avoid_tyop
def kg8m#util#check_typo#setup(): void
  augroup vimrc-util-check_typo
    autocmd!
    autocmd BufWriteCmd *[,*] s:check_typo(expand("<afile>"))
  augroup END
enddef

def s:check_typo(file: string): void
  const writecmd = "write" .. (v:cmdbang ? "!" : "") .. " " .. file

  if file =~? '[qfreplace]'
    return
  endif

  const prompt = "possible typo: really want to write to '" .. file .. "'? (y/n):"
  const input = input(prompt)

  if input =~? '^y'
    execute writecmd
  endif
enddef
