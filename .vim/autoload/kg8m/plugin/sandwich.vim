function kg8m#plugin#sandwich#configure() abort  " {{{
  let g:sandwich_no_default_key_mappings = v:true
  let g:operator_sandwich_no_default_key_mappings = v:true
  let g:textobj_sandwich_no_default_key_mappings = v:true

  vmap <Leader>sa <Plug>(operator-sandwich-add)
  nmap <Leader>sd <Plug>(operator-sandwich-delete)<Plug>(textobj-sandwich-query-a)
  nmap <Leader>sr <Plug>(operator-sandwich-replace)<Plug>(textobj-sandwich-query-a)

  " Textobjects to select a text surrounded by braket or same characters user input
  xmap iS <Plug>(textobj-sandwich-query-i)
  xmap aS <Plug>(textobj-sandwich-query-a)
  omap iS <Plug>(textobj-sandwich-query-i)
  omap aS <Plug>(textobj-sandwich-query-a)

  nmap . <Plug>(operator-sandwich-dot)

  call kg8m#plugin#configure(#{
  \   lazy:   v:true,
  \   on_map: [["nv", "<Plug>(operator-sandwich-"], ["xo", "<Plug>(textobj-sandwich-"]],
  \   hook_post_source: function("s:on_post_source"),
  \ })
endfunction  " }}}

function s:surround_like_recipes() abort  " {{{
  let add_options    = extend(#{ kind: ["add", "replace"], action: ["add"] }, s:common_options())
  let delete_options = extend(#{ kind: ["delete", "replace", "textobj"], action: ["delete"], regex: v:true }, s:common_options())

  return [
  \   extend(#{ buns: ["( ", " )"], input: ["("] }, add_options),
  \   extend(#{ buns: ["[ ", " ]"], input: ["["] }, add_options),
  \   extend(#{ buns: ["{ ", " }"], input: ["{"] }, add_options),
  \   extend(#{ buns: ['[(（]\s*', '\s*[)）]'], input: ["(", ")"] }, delete_options),
  \   extend(#{ buns: ['[[［]\s*', '\s*[\]］]'], input: ["[", "]"] }, delete_options),
  \   extend(#{ buns: ['[{｛]\s*', '\s*[}｝]'], input: ["{", "}"] }, delete_options),
  \ ]
endfunction  " }}}

function s:zenkaku_recipes() abort  " {{{
  let options = extend(#{ kind: ["add", "delete", "replace", "textobj"], action: ["add", "delete"] }, s:common_options())
  return kg8m#util#japanese_matchpairs()->map({ _, pair -> extend(#{ buns: pair, input: pair }, options) })
endfunction  " }}}

function s:common_options() abort  " {{{
  return #{ nesting: v:true, match_syntax: v:true }
endfunction  " }}}

function s:on_post_source() abort  " {{{
  let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + s:surround_like_recipes() + s:zenkaku_recipes()
endfunction  " }}}
