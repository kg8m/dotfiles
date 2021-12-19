vim9script

g:kg8m#configure#colors#sync_minlines = 1000

def kg8m#configure#colors#terminal(): void
  set termguicolors

  g:terminal_ansi_colors = [
    # Black,     Dark Red,     Dark GreeN, Brown,
    # Dark Blue, Dark Magenta, Dark Cyan,  Light Gray,
    # Dark Gray, Red,          Green,      YellOw,
    # Blue,      Magenta,      Cyan,       White,
    "#000000",   "#F92672",    "#BAED00",  "#EBCE00",
    "#00BEF3",   "#BAA0F0",    "#71C0ED",  "#EAEAEA",
    "#888888",   "#FA397E",    "#C1F600",  "#FFE000",
    "#00C2F9",   "#C6ABFF",    "#79CEFF",  "#FFFFFF",
  ]
enddef

def kg8m#configure#colors#colorscheme(): void
  colorscheme molokai
enddef

def kg8m#configure#colors#performance(): void
  augroup my_vimrc
    # minlines: Prevent broken syntax highlighting.
    # maxlines: Prevent too slow syntax highlighting.
    # cf. `:h :syn-sync-maxlines` / `:h :syn-sync-minlines`
    execute "autocmd Syntax * syntax sync minlines=" .. g:kg8m#configure#colors#sync_minlines .. " maxlines=2000"
  augroup END

  set maxmempattern=5000
  set redrawtime=5000

  set lazyredraw
  set ttyfast
enddef
