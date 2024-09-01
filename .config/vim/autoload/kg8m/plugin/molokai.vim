vim9script

# DiffAdd: `#002400` is delta’s plus green.
# DiffAdded: `#002400` is delta’s plus green. `#e5e9e5` is lightened `#002400`.
# DiffDelete: `#370001` is delta’s minus red.
# DiffRemoved: `#370001` is delta’s minus red. `#af9999` is lightened `#370001`.
#
# DiffAdd/DiffChange/DiffDelete/DiffText: for patch mode with syntax highlighting, e.g., `:GinPatch`.
# DiffAdded/DiffFile/DiffRemoved: for `diff` filetype buffer contents, e.g., `foo.diff`.
export def Overwrite(): void
  highlight Comment       guifg=#aaaaaa
  highlight ColorColumn                  guibg=#1f1e19
  highlight CursorColumn                 guibg=#4b4a46
  highlight CursorLine                   guibg=#4b4a46
  highlight DiffAdd                      guibg=#002400
  highlight DiffAdded     guifg=#e5e9e5  guibg=#002400
  highlight DiffDelete                   guibg=#370001
  highlight DiffChange    guifg=NONE     guibg=#222222
  highlight DiffFile      guifg=#ebce00                 gui=bold         cterm=bold
  highlight DiffRemoved   guifg=#af9999  guibg=#370001
  highlight DiffText      guifg=#ffffff  guibg=#333333  gui=bold,italic  cterm=bold,italic
  highlight FoldColumn    guifg=#6a7678  guibg=NONE
  highlight Folded        guifg=#6a7678  guibg=NONE
  highlight Ignore                       guibg=NONE
  highlight Incsearch     guifg=#eaeaea  guibg=#f92672
  highlight LineNr                       guibg=#222222
  highlight Normal        guifg=#eaeaea  guibg=NONE
  highlight Pmenu                        guibg=#00161c
  highlight QuickFixLine                                gui=bold         cterm=bold
  highlight Search        guifg=#eaeaea  guibg=#f92672
  highlight SignColumn                   guibg=#111111
  highlight Title         guifg=#a6e22e                 gui=bold         cterm=bold
  highlight Todo                         guibg=NONE
  highlight Underlined    guifg=#aaaaaa
  highlight Visual                                      gui=bold         cterm=bold
  highlight VisualNOS                                   gui=bold         cterm=bold
  highlight WarningMsg    guifg=#e6db74

  if has("gui_running")
    # `guibg=NONE` doesn’t work in GUI Vim
    highlight FoldColumn  guibg=#000000
    highlight Folded      guibg=#000000
    highlight Ignore      guibg=#000000
    highlight Normal      guibg=#000000
    highlight Todo        guibg=#000000
  endif
enddef
