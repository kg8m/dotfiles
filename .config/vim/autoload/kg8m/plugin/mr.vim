vim9script

const PLUGINS_ROOT_DIRPATH = simplify($"{$VIM_PLUGINS}/..")
const SESSIONS_BASEDIR_PATH = g:kg8m#plugin#startify#sessions_basedir_path
const SESSION_NAME_PATTERN = kg8m#plugin#startify#SessionFilename("")
const IGNORE_PATTERNS = [
  '\v^/usr/local/share/vim/.+/doc/',
  $'\V\^{PLUGINS_ROOT_DIRPATH}/\.\+/doc/',
  $'\V\^{SESSIONS_BASEDIR_PATH}/\.\+/{SESSION_NAME_PATTERN}',
]

export def Configure(): void
  g:mr_mrw_disabled = true
  g:mr_mrr_disabled = true
  g:mr#threshold = 10'000
  g:mr#mru#filename = $"{$XDG_DATA_HOME}/vim/mr/mru"
  g:mr#mru#predicates = [Predicate]
enddef

def Predicate(filepath: string): bool
  return kg8m#util#list#All(IGNORE_PATTERNS, (pattern) => filepath !~# pattern)
enddef
