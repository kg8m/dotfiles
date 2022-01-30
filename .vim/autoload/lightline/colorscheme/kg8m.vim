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

const s:base    = [ s:white, s:light_gray ]
const s:error   = [ s:white, s:red ]
const s:warning = [ s:black, s:white ]

g:lightline#colorscheme#kg8m#palette = lightline#colorscheme#flatten({
  normal: {
    left:    [ [ s:black, s:sand ], s:base ],
    middle:  [ s:base ],
    right:   [ s:base ],
    error:   [ s:error ],
    warning: [ s:warning ],
  },
  inactive: {
    left: [ [ s:black, s:sand ], s:base ],
  },
  insert: {
    left: [ [ s:black, s:blue ], s:base ],
  },
  replace: {
    left: [ [ s:black, s:green ], s:base ],
  },
  visual: {
    left: [ [ s:black, s:orange ], s:base ],
  },
  tabline: {
    left:   [ s:base ],
    tabsel: [ [ s:black, s:sand ] ],
  },
})
