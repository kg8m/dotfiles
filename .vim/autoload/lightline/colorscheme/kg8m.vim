vim9script

const s:true_black = [ "#000000",   0 ]
const s:black      = [ "#121212", 233 ]
const s:dark_gray  = [ "#1c1c1c", 234 ]
const s:gray       = [ "#262626", 235 ]
const s:light_gray = [ "#444444", 242 ]
const s:white      = [ "#ffffff", 255 ]
const s:sand       = [ "#e6db74", 144 ]
const s:blue       = [ "#66d9ef",  81 ]
const s:green      = [ "#a6e22e", 118 ]
const s:orange     = [ "#fd971f", 208 ]
const s:red        = [ "#f92672", 161 ]

g:lightline#colorscheme#kg8m#palette = lightline#colorscheme#flatten({
  normal: {
    left:    [ [ s:black, s:sand ], [ s:white, s:light_gray ] ],
    middle:  [ [ s:white, s:light_gray ] ],
    right:   [ [ s:white, s:light_gray ] ],
    error:   [ [ s:white, s:red ] ],
    warning: [ [ s:black, s:white ] ],
  },
  inactive: {
    left:   [ [ s:black, s:sand ], [ s:white, s:light_gray ] ],
    middle: [ [ s:white, s:light_gray ] ],
    right:  [ [ s:white, s:light_gray ] ],
  },
  insert: {
    left:   [ [ s:black, s:blue ], [ s:white, s:light_gray ] ],
    middle: [ [ s:white, s:light_gray ] ],
    right:  [ [ s:white, s:light_gray ] ],
  },
  replace: {
    left:   [ [ s:black, s:green ], [ s:white, s:light_gray ] ],
    middle: [ [ s:white, s:light_gray ] ],
    right:  [ [ s:white, s:light_gray ] ],
  },
  visual: {
    left:   [ [ s:black, s:orange ], [ s:white, s:light_gray ] ],
    middle: [ [ s:white, s:light_gray ] ],
    right:  [ [ s:white, s:light_gray ] ],
  },
  tabline: {
    left:   [ [ s:white, s:light_gray ] ],
    tabsel: [ [ s:black, s:sand ] ],
    middle: [ [ s:white, s:light_gray ] ],
    right:  [ [ s:white, s:light_gray ] ],
  },
})
