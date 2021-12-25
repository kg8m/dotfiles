vim9script

def kg8m#plugin#molokai#configure(): void
  g:molokai_original = true

  augroup vimrc-plugin-molokai
    autocmd!
    autocmd ColorScheme molokai s:overwrite()
  augroup END
enddef

def s:overwrite(): void
  highlight Comment       guifg=#AAAAAA
  highlight ColorColumn                  guibg=#1F1E19
  highlight CursorColumn                 guibg=#4B4A46
  highlight CursorLine                   guibg=#4B4A46
  highlight DiffChange    guifg=#CCCCCC
  highlight DiffFile      guifg=#EBCE00                 gui=bold  cterm=bold
  highlight FoldColumn    guifg=#6A7678  guibg=NONE
  highlight Folded        guifg=#6A7678  guibg=NONE
  highlight Ignore                       guibg=NONE
  highlight Incsearch     guifg=#EAEAEA  guibg=#F92672
  highlight LineNr                       guibg=#222222
  highlight Normal        guifg=#EAEAEA  guibg=NONE
  highlight Pmenu                        guibg=#00161C
  highlight QuickFixLine                                gui=bold  cterm=bold
  highlight Search        guifg=#EAEAEA  guibg=#F92672
  highlight SignColumn                   guibg=#111111
  highlight Special                      guibg=NONE     gui=bold  cterm=bold
  highlight Todo                         guibg=NONE
  highlight Underlined    guifg=#AAAAAA
  highlight Visual                                      gui=bold  cterm=bold
  highlight VisualNOS                                   gui=bold  cterm=bold

  if has("gui_running")
    # `guibg=NONE` doesn't work in GUI Vim
    highlight FoldColumn  guibg=#000000
    highlight Folded      guibg=#000000
    highlight Ignore      guibg=#000000
    highlight Normal      guibg=#000000
    highlight Special     guibg=#000000
    highlight Todo        guibg=#000000
  endif
enddef
