vim9script

# Special: Disable bold/italic for balance between `DiffAdded` (=> `Identifier`) and `DiffRemoved` (=> `Special`).
export def Overwrite(): void
  highlight Comment       guifg=#aaaaaa
  highlight ColorColumn                  guibg=#1f1e19
  highlight CursorColumn                 guibg=#4b4a46
  highlight CursorLine                   guibg=#4b4a46
  highlight DiffChange    guifg=#cccccc
  highlight DiffFile      guifg=#ebce00                 gui=bold  cterm=bold
  highlight FoldColumn    guifg=#6a7678  guibg=NONE
  highlight Folded        guifg=#6a7678  guibg=NONE
  highlight Ignore                       guibg=NONE
  highlight Incsearch     guifg=#eaeaea  guibg=#f92672
  highlight LineNr                       guibg=#222222
  highlight Normal        guifg=#eaeaea  guibg=NONE
  highlight Pmenu                        guibg=#00161c
  highlight QuickFixLine                                gui=bold  cterm=bold
  highlight Search        guifg=#eaeaea  guibg=#f92672
  highlight SignColumn                   guibg=#111111
  highlight Special                      guibg=NONE     gui=NONE  cterm=NONE
  highlight Title         guifg=#a6e22e                 gui=bold  cterm=bold
  highlight Todo                         guibg=NONE
  highlight Underlined    guifg=#aaaaaa
  highlight Visual                                      gui=bold  cterm=bold
  highlight VisualNOS                                   gui=bold  cterm=bold
  highlight WarningMsg    guifg=#e6db74

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
