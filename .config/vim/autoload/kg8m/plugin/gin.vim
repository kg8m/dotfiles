vim9script

export def Edit(filepath: string = expand("%")): void
  const commitish = input("Commitish (optional): ")
  execute "GinEdit" commitish fnameescape(filepath)
enddef

export def Patch(filepath: string = expand("%")): void
  tabedit
  execute "GinPatch ++no-head" fnameescape(filepath)
enddef
