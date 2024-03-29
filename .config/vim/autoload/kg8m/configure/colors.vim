vim9script

export const SYNC_MINLINES = 1000

export def Terminal(): void
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

export def Performance(): void
  augroup vimrc-configure-colors-performance
    autocmd!

    # minlines: Prevent broken syntax highlighting.
    # maxlines: Prevent too slow syntax highlighting.
    # cf. `:h :syn-sync-maxlines` / `:h :syn-sync-minlines`
    execute $"autocmd Syntax * syntax sync minlines={SYNC_MINLINES} maxlines=2000"
  augroup END

  set maxmempattern=5000
  set redrawtime=5000

  set lazyredraw
enddef
