vim9script

def kg8m#plugin#gina#configure(): void  # {{{
  kg8m#plugin#configure({
    lazy:   v:true,
    on_cmd: "Gina",
  })
enddef  # }}}

def kg8m#plugin#gina#patch(filepath: string): void  # {{{
  const original_diffopt = &diffopt

  try
    set diffopt+=vertical
    execute "Gina patch --oneside " .. filepath
  finally
    &diffopt = original_diffopt
  endtry
enddef  # }}}
