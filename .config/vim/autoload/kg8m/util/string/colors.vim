vim9script

# cf. zsh’s `highlight:red` and so on
const COLOR_CODES = {
  red:     1,
  green:   2,
  yellow:  3,
  blue:    4,
  magenta: 5,
  cyan:    6,
  pink:    219,
  gray:    245,
}

export def Red(string: string, options: dict<any> = {}): string
  return WithColorSequence("red", string, options)
enddef

export def Green(string: string, options: dict<any> = {}): string
  return WithColorSequence("green", string, options)
enddef

export def Yellow(string: string, options: dict<any> = {}): string
  return WithColorSequence("yellow", string, options)
enddef

export def Blue(string: string, options: dict<any> = {}): string
  return WithColorSequence("blue", string, options)
enddef

export def Magenta(string: string, options: dict<any> = {}): string
  return WithColorSequence("magenta", string, options)
enddef

export def Cyan(string: string, options: dict<any> = {}): string
  return WithColorSequence("cyan", string, options)
enddef

export def Pink(string: string, options: dict<any> = {}): string
  return WithColorSequence("pink", string, options)
enddef

export def Gray(string: string, options: dict<any> = {}): string
  return WithColorSequence("gray", string, options)
enddef

def WithColorSequence(color_name: string, string: string, options: dict<any> = {}): string
  const color = COLOR_CODES[color_name]
  const style = get(options, "bold", true) ? 1 : 0
  const fgbg  = get(options, "bg", false) ? 48 : 38

  return $"\e[{style};{fgbg};5;{color}m{string}\e[0;0m"
enddef
