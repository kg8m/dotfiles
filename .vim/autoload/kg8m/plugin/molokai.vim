vim9script

def kg8m#plugin#molokai#configure(): void
  g:molokai_original = true

  augroup my_vimrc
    autocmd ColorScheme molokai s:overwrite()
  augroup END
enddef

def s:overwrite(): void
  highlight Comment       guifg=#AAAAAA
  highlight ColorColumn                  guibg=#1F1E19
  highlight CursorColumn                 guibg=#1F1E19
  highlight CursorLine                   guibg=#1F1E19
  highlight DiffChange    guifg=#CCCCCC  guibg=#4C4745
  highlight DiffFile      guifg=#A6E22E                 gui=bold       cterm=bold
  highlight FoldColumn    guifg=#6A7678  guibg=NONE
  highlight Folded        guifg=#6A7678  guibg=NONE
  highlight Ignore        guifg=#808080  guibg=NONE
  highlight Incsearch     guifg=#FFFFFF  guibg=#F92672
  highlight LineNr        guifg=#BCBCBC  guibg=#222222
  highlight Normal        guifg=#F8F8F8  guibg=NONE
  highlight Pmenu         guifg=#66D9EF  guibg=NONE
  highlight QuickFixLine                                gui=bold       cterm=bold
  highlight Search        guifg=#FFFFFF  guibg=#F92672
  highlight SignColumn    guifg=#A6E22E  guibg=#111111
  highlight Special       guifg=#66D9EF  guibg=NONE     gui=italic
  highlight Todo          guifg=#FFFFFF  guibg=NONE     gui=bold
  highlight Underlined    guifg=#AAAAAA                 gui=underline  cterm=underline
  highlight Visual                       guibg=#403D3D  gui=bold       cterm=bold
  highlight VisualNOS                    guibg=#403D3D  gui=bold       cterm=bold

  if has("gui_running")
    # `guibg=NONE` doesn't work in GUI Vim
    highlight FoldColumn  guibg=#000000
    highlight Folded      guibg=#000000
    highlight Ignore      guibg=#000000
    highlight Normal      guibg=#000000
    highlight Pmenu       guibg=#000000
    highlight Special     guibg=#000000
    highlight Todo        guibg=#000000
  endif
enddef
