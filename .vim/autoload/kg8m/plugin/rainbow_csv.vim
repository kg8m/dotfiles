vim9script

def kg8m#plugin#rainbow_csv#configure(): void
  augroup vimrc-plugin-rainbow_csv
    autocmd!
    autocmd BufNewFile,BufRead *.csv set filetype=csv
  augroup END

  kg8m#plugin#configure({
    lazy:  true,
    on_ft: "csv",
  })
enddef
