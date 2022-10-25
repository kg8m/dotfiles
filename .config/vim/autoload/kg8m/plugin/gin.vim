vim9script

export def Patch(filepath: string): void
  tabedit
  execute "GinPatch ++no-head" fnameescape(filepath)
enddef
