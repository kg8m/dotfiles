vim9script

import autoload "kg8m/plugin.vim"
import autoload "kg8m/util/matchpairs.vim"

export def OnSource(): void
  g:sandwich_no_default_key_mappings = true
  g:operator_sandwich_no_default_key_mappings = true
  g:textobj_sandwich_no_default_key_mappings = true
enddef

export def OnPostSource(): void
  g:sandwich#recipes = DefaultRecipes()
enddef

export def OperatorDeleteExpr(): string
  const key = getcharstr()
  const recipes = DeleterRecipesFor(key)
  UseTemporaryRecipes(recipes)

  return "\<Plug>(operator-sandwich-delete)\<Plug>(textobj-sandwich-auto-a)"
enddef

export def OperatorReplaceExpr(): string
  const adder_recipes = DefaultRecipes()->mapnew((_, recipe) => {
    final new_recipe = copy(recipe)
    new_recipe.action = ["add", "replace"]
    return new_recipe
  })

  const key = getcharstr()
  const deleter_recipes = DeleterRecipesFor(key)
  UseTemporaryRecipes(adder_recipes + deleter_recipes)

  return "\<Plug>(operator-sandwich-replace)\<Plug>(textobj-sandwich-auto-a)"
enddef

export def AutoTextobjExpr(key: string, mode: string, a_or_i: string): string
  return textobj#sandwich#auto(mode, a_or_i, {}, AutoRecipesFor(key))
enddef

def UseTemporaryRecipes(temporary_recipes: list<dict<any>>): void
  g:sandwich#recipes = temporary_recipes
  autocmd SafeState <buffer> ++once g:sandwich#recipes = DefaultRecipes()
enddef

def AdderRecipesFor(key: string): list<dict<any>>
  return RecipesFor(key, (key_pair, japanese_pairs) => {
    const key_recipes      = mapnew(key_pair, (_, key_or_another) => BuildAdderRecipe(key_pair, [key_or_another]))
    const japanese_recipes = mapnew(japanese_pairs, (_, pair) => BuildAdderRecipe(pair, pair))
    return key_recipes + japanese_recipes
  })
enddef

def DeleterRecipesFor(key: string): list<dict<any>>
  return RecipesFor(key, (key_pair, japanese_pairs) => {
    const key_recipes      = [BuildDeleterRecipe(key_pair, key_pair)]
    const japanese_recipes = mapnew(japanese_pairs, (_, pair) => BuildDeleterRecipe(pair, key_pair))
    return key_recipes + japanese_recipes
  })
enddef

def AutoRecipesFor(key: string): list<dict<any>>
  return RecipesFor(key, (key_pair, japanese_pairs) => {
    const key_recipes      = [BuildAutoRecipe(key_pair)]
    const japanese_recipes = mapnew(japanese_pairs, (_, pair) => BuildAutoRecipe(pair))
    return key_recipes + japanese_recipes
  })
enddef

def RecipesFor(raw_key: string, Build: func): list<dict<any>>
  const key = matchpairs.NormalizeKey(raw_key)
  const japanese_pairs = get(matchpairs.GroupedJapanesePairs(), key, [])

  if japanese_pairs ==# []
    return [BuildFallbackRecipe(key)]
  else
    const key_pair = matchpairs.KeyPairFor(key)
    return Build(key_pair, japanese_pairs)
  endif
enddef

def DefaultRecipes(): list<dict<any>>
  const keys = keys(matchpairs.GroupedJapanesePairs())
  const adder_recipes   = reduce(keys, (recipes, key) => recipes + AdderRecipesFor(key), [])
  const deleter_recipes = reduce(keys, (recipes, key) => recipes + DeleterRecipesFor(key), [])

  return deepcopy(g:sandwich#default_recipes) + adder_recipes + deleter_recipes
enddef

def BuildAdderRecipe(matchpair: list<string>, input: list<string>): dict<any>
  const is_start_key = matchpairs.IsBasicStartKey(input[0])

  return extendnew({
    # For surround.vim-like behavior:
    #   - `foo` => `( foo )` with `(`
    #   - `foo` => `(foo)`   with `)`
    buns: is_start_key && len(input) ==# 1 ? [$"{matchpair[0]} ", $" {matchpair[1]}"] : matchpair,

    input: input,
    kind: ["add", "replace", "auto"],
    action: ["add"],
  }, CommonRecipeOptionsFor(matchpair))
enddef

def BuildDeleterRecipe(matchpair: list<string>, input: list<string>): dict<any>
  return extendnew({
    # For surround.vim-like behavior:
    #   - `( foo )` => `foo` with `(` or `)`
    #   - `(foo)`   => `foo` with `(` or `)`
    buns: [$'\V{matchpair[0]}\s\*', $'\V\s\*{matchpair[1]}'],

    input: input,
    kind: ["delete", "replace", "textobj", "auto"],
    action: ["delete"],
    regex: true,
  }, CommonRecipeOptionsFor(matchpair))
enddef

def BuildAutoRecipe(matchpair: list<string>): dict<any>
  return extendnew({
    buns: matchpair,
    kind: ["textobj", "auto"],
  }, CommonRecipeOptionsFor(matchpair))
enddef

def BuildFallbackRecipe(key: string): dict<any>
  const matchpair = [key, key]

  return extendnew({
    buns: matchpair,
    input: matchpair,
    kind: ["add", "delete", "replace", "textobj", "auto"],
    action: ["add", "delete"],
  }, CommonRecipeOptionsFor(matchpair))
enddef

def CommonRecipeOptionsFor(matchpair: list<string>): dict<any>
  return {
    nesting: matchpair[0] !=# matchpair[1],
    match_syntax: 1,
    quoteescape: matchpair[0] ==# '"' || matchpair[0] ==# "'",
  }
enddef

plugin.EnsureSourced("vim-sandwich")
