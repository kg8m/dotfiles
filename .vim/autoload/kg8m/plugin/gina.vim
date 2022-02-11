vim9script

export def Patch(filepath: string): void
  const original_diffopt = &diffopt

  try
    set diffopt+=vertical
    execute "Gina patch --oneside " .. filepath
  finally
    &diffopt = original_diffopt
  endtry
enddef
