vim9script

def kg8m#plugin#sandwich#configure(): void  # {{{
  g:sandwich_no_default_key_mappings = v:true
  g:operator_sandwich_no_default_key_mappings = v:true
  g:textobj_sandwich_no_default_key_mappings = v:true

  vmap <Leader>sa <Plug>(operator-sandwich-add)
  nmap <Leader>sd <Plug>(operator-sandwich-delete)<Plug>(textobj-sandwich-query-a)
  nmap <Leader>sr <Plug>(operator-sandwich-replace)<Plug>(textobj-sandwich-query-a)

  # Textobjects to select a text surrounded by braket or same characters user input
  xmap iS <Plug>(textobj-sandwich-query-i)
  xmap aS <Plug>(textobj-sandwich-query-a)
  omap iS <Plug>(textobj-sandwich-query-i)
  omap aS <Plug>(textobj-sandwich-query-a)

  nmap . <Plug>(operator-sandwich-dot)

  kg8m#plugin#configure({
    lazy:   v:true,
    on_map: [["nv", "<Plug>(operator-sandwich-"], ["xo", "<Plug>(textobj-sandwich-"]],
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

def s:surround_like_recipes(): list<dict<any>>  # {{{
  const add_options    = extend({ kind: ["add", "replace"], action: ["add"] }, s:common_options())
  const delete_options = extend({ kind: ["delete", "replace", "textobj"], action: ["delete"], regex: v:true }, s:common_options())

  return [
    extend({ buns: ["( ", " )"], input: ["("] }, add_options),
    extend({ buns: ["[ ", " ]"], input: ["["] }, add_options),
    extend({ buns: ["{ ", " }"], input: ["{"] }, add_options),
    extend({ buns: ['[(（]\s*', '\s*[)）]'], input: ["(", ")"] }, delete_options),
    extend({ buns: ['[[［]\s*', '\s*[\]］]'], input: ["[", "]"] }, delete_options),
    extend({ buns: ['[{｛]\s*', '\s*[}｝]'], input: ["{", "}"] }, delete_options),
  ]
enddef  # }}}

def s:zenkaku_recipes(): list<dict<any>>  # {{{
  const options = extend({ kind: ["add", "delete", "replace", "textobj"], action: ["add", "delete"] }, s:common_options())
  return kg8m#util#japanese_matchpairs()->map({ _, pair -> extend({ buns: pair, input: pair }, options) })
enddef  # }}}

def s:common_options(): dict<any>  # {{{
  return { nesting: v:true, match_syntax: v:true }
enddef  # }}}

def s:on_post_source(): void  # {{{
  # Don't use `deepcopy(g:sandwich#default_recipes)` because it raises "E121: Undefined variable:
  # g:sandwich#default_recipes" in Vim9 script. `sandwich#get_recipes` returns deepcopied `g:sandwich#default_recipes`
  # if neither `b:sanwich_recipes` nor `g:sandwich#recipes` are defined.
  g:sandwich#recipes = sandwich#get_recipes() + s:surround_like_recipes() + s:zenkaku_recipes()
enddef  # }}}
