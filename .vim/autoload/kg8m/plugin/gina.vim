function kg8m#plugin#gina#configure() abort  " {{{
  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_cmd: "Gina",
  \ })
endfunction  " }}}

function kg8m#plugin#gina#patch(filepath) abort  " {{{
  let original_diffopt = &diffopt

  try
    set diffopt+=vertical
    execute "Gina patch --oneside "..a:filepath
  finally
    let &diffopt = original_diffopt
  endtry
endfunction  " }}}
