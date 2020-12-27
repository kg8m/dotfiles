vim9script

def kg8m#plugin#jasentence#configure(): void  # {{{
  g:jasentence_endpat = '[。．？！!?]\+'

  kg8m#plugin#configure({
    lazy:   true,
    on_map: [["nv", "("], ["nv", ")"], ["o", "s"]],
  })
enddef  # }}}
