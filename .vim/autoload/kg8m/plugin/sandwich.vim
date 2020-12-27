vim9script

def kg8m#plugin#sandwich#configure(): void  # {{{
  g:sandwich_no_default_key_mappings = true
  g:operator_sandwich_no_default_key_mappings = true
  g:textobj_sandwich_no_default_key_mappings = true

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
    lazy:   true,
    on_map: [["nv", "<Plug>(operator-sandwich-"], ["xo", "<Plug>(textobj-sandwich-"]],
    hook_post_source: function("s:on_post_source"),
  })
enddef  # }}}

def s:surround_like_recipes(): list<dict<any>>  # {{{
  const add_options    = extend({ kind: ["add", "replace"], action: ["add"] }, s:common_options())
  const delete_options = extend({ kind: ["delete", "replace", "textobj"], action: ["delete"], regex: true }, s:common_options())

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
  return { nesting: true, match_syntax: true }
enddef  # }}}

def s:on_post_source(): void  # {{{
  g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + s:surround_like_recipes() + s:zenkaku_recipes()
enddef  # }}}
