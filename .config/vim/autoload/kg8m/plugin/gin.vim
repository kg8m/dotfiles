vim9script

export def Patch(filepath: string): void
  tabedit
  execute printf("GinPatch ++no-head %s", fnameescape(filepath))
enddef
