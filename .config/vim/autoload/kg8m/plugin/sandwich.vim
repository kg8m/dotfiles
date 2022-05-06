vim9script

export def Configure(): void
  xmap <Leader>sa <Plug>(operator-sandwich-add)
  nmap <Leader>sd <Plug>(operator-sandwich-delete)<Plug>(textobj-sandwich-query-a)
  nmap <Leader>sr <Plug>(operator-sandwich-replace)<Plug>(textobj-sandwich-query-a)

  # Textobjects to select a text surrounded by braket or same characters user input
  xmap iS <Plug>(textobj-sandwich-query-i)
  xmap aS <Plug>(textobj-sandwich-query-a)
  omap iS <Plug>(textobj-sandwich-query-i)
  omap aS <Plug>(textobj-sandwich-query-a)

  nmap . <Plug>(operator-sandwich-dot)

  kg8m#plugin#Configure({
    lazy:   true,
    on_map: { nx: "<Plug>(operator-sandwich-", xo: "<Plug>(textobj-sandwich-" },
    hook_source:      () => OnSource(),
    hook_post_source: () => OnPostSource(),
  })
enddef

def SurroundLikeRecipes(): list<dict<any>>
  const add_options    = extendnew({ kind: ["add", "replace"], action: ["add"] }, CommonOptions())
  const delete_options = extendnew({ kind: ["delete", "replace", "textobj"], action: ["delete"], regex: true }, CommonOptions())

  return [
    extendnew({ buns: ["( ", " )"], input: ["("] }, add_options),
    extendnew({ buns: ["[ ", " ]"], input: ["["] }, add_options),
    extendnew({ buns: ["{ ", " }"], input: ["{"] }, add_options),
    extendnew({ buns: ['[(（]\s*',         '\s*[)）]'],          input: ["(", ")"] }, delete_options),
    extendnew({ buns: ['[[［「『〔〈]\s*', '\s*[\]］」』〕〉]'], input: ["[", "]"] }, delete_options),
    extendnew({ buns: ['[{｛【]\s*',       '\s*[}｝】]'],        input: ["{", "}"] }, delete_options),
  ]
enddef

def ZenkakuRecipes(): list<dict<any>>
  const options = extendnew({ kind: ["add", "delete", "replace", "textobj"], action: ["add", "delete"] }, CommonOptions())
  return kg8m#util#JapaneseMatchpairs()->mapnew((_, pair) => extendnew({ buns: pair, input: pair }, options))
enddef

def CommonOptions(): dict<any>
  return { nesting: true, match_syntax: true }
enddef

def OnSource(): void
  g:sandwich_no_default_key_mappings = true
  g:operator_sandwich_no_default_key_mappings = true
  g:textobj_sandwich_no_default_key_mappings = true
enddef

def OnPostSource(): void
  g:sandwich#recipes = deepcopy(g:sandwich#default_recipes) + SurroundLikeRecipes() + ZenkakuRecipes()
enddef
