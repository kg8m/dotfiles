vim9script

# http://vim-users.jp/2010/01/hack120/

const s:filepath = expand("~/.vim/gui-window-info")

def kg8m#configure#gui#window_size#setup(): void
  augroup my_vimrc
    autocmd VimLeavePre * s:save()
  augroup END

  if has("vim_starting") && filereadable(s:filepath)
    execute "source " .. s:filepath
  endif
enddef

def s:save(): void
  const options = [
    "set columns=" .. &columns,
    "set lines=" .. &lines,
    "winpos " .. getwinposx() .. " " .. getwinposy(),
  ]

  writefile(options, s:filepath)
enddef
