vim9script

export def Patch(filepath: string = expand("%")): void
  tabedit
  execute "GinPatch ++no-head" fnameescape(filepath)
enddef
