vim9script

const true_black = ["#000000",   0]
const black      = ["#121212", 233]
const dark_gray  = ["#1c1c1c", 234]
const gray       = ["#262626", 235]
const light_gray = ["#444444", 242]
const white      = ["#ffffff", 255]
const sand       = ["#e6db74", 144]
const blue       = ["#66d9ef",  81]
const green      = ["#a6e22e", 118]
const orange     = ["#fd971f", 208]
const red        = ["#f92672", 161]

const base    = [white, light_gray]
const error   = [white, red]
const warning = [black, white]

g:lightline#colorscheme#kg8m#palette = lightline#colorscheme#flatten({
  normal: {
    left:    [[black, sand], base],
    middle:  [base],
    right:   [base],
    error:   [error],
    warning: [warning],
  },
  inactive: {
    left: [[black, sand], base],
  },
  insert: {
    left: [[black, blue], base],
  },
  replace: {
    left: [[black, green], base],
  },
  visual: {
    left: [[black, orange], base],
  },
  tabline: {
    left:   [base],
    tabsel: [[black, sand]],
  },
})
