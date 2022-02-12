vim9script

const COLORS = {
  true_black: ["#000000",   0],
  black:      ["#121212", 233],
  dark_gray:  ["#1c1c1c", 234],
  gray:       ["#262626", 235],
  light_gray: ["#444444", 242],
  white:      ["#ffffff", 255],
  sand:       ["#e6db74", 144],
  blue:       ["#66d9ef",  81],
  green:      ["#a6e22e", 118],
  orange:     ["#fd971f", 208],
  red:        ["#f92672", 161],
}

const GROUPS = {
  base:    [COLORS.white, COLORS.light_gray],
  error:   [COLORS.white, COLORS.red],
  warning: [COLORS.black, COLORS.white],
  modes:   {
    normal:  [COLORS.black, COLORS.sand],
    insert:  [COLORS.black, COLORS.blue],
    replace: [COLORS.black, COLORS.green],
    visual:  [COLORS.black, COLORS.orange],
  },
}

g:lightline#colorscheme#kg8m#palette = lightline#colorscheme#flatten({
  normal: {
    left:    [GROUPS.modes.normal, GROUPS.base],
    middle:  [GROUPS.base],
    right:   [GROUPS.base],
    error:   [GROUPS.error],
    warning: [GROUPS.warning],
  },
  inactive: {
    left: [GROUPS.modes.normal, GROUPS.base],
  },
  insert: {
    left: [GROUPS.modes.insert, GROUPS.base],
  },
  replace: {
    left: [GROUPS.modes.replace, GROUPS.base],
  },
  visual: {
    left: [GROUPS.modes.visual, GROUPS.base],
  },
  tabline: {
    left:   [GROUPS.base],
    tabsel: [GROUPS.modes.normal],
  },
})
