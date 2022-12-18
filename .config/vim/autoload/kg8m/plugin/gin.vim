vim9script

export def Configure(): void
  kg8m#plugin#Configure({
    lazy:    true,
    on_cmd:  ["GinEdit", "GinPatch"],
    depends: ["denops.vim"],
  })
enddef

export def Edit(filepath: string = expand("%")): void
  const commitish = input("Commitish (optional): ")
  execute "GinEdit" commitish fnameescape(filepath)
enddef

export def Patch(filepath: string = expand("%")): void
  tabedit
  execute "GinPatch ++no-head" fnameescape(filepath)
enddef
