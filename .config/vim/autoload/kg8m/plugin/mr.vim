vim9script

const PLUGINS_ROOT_DIRPATH = simplify($"{$VIM_PLUGINS}/..")
const IGNORE_PATTERN = '\v' .. join([
  '^/usr/local/share/vim/.+/doc/',
  $'^{PLUGINS_ROOT_DIRPATH}/.+/doc/',
], '|')

export def Configure(): void
  g:mr_mrw_disabled = true
  g:mr_mrr_disabled = true
  g:mr#threshold = 10'000
  g:mr#mru#filename = $"{$XDG_DATA_HOME}/vim/mr/mru"
  g:mr#mru#predicates = [Predicate]
enddef

def Predicate(filepath: string): bool
  return filepath !~# IGNORE_PATTERN
enddef
