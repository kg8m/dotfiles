vim9script

export def Confirm(prompt: string): bool
  var input = ""

  while input !~? '^[yn]'
    input = GetNonBlank(prompt)
  endwhile

  return input =~? '^y'
enddef

export def GetNonBlank(prompt: string): string
  var input = ""

  while empty(input)
    input = input(prompt)
  endwhile

  return input
enddef
