vim9script

import autoload "kg8m/plugin/startify.vim"
import autoload "kg8m/util/list.vim" as listUtil

const PLUGINS_ROOT_DIRPATH = simplify($"{$VIM_PLUGINS}/..")
const SESSIONS_BASEDIR_PATH = startify.SESSIONS_BASEDIR_PATH
const SESSION_NAME_PATTERN = startify.SessionFilename("")
const VIEW_DIRPATH = expand(&viewdir)
const IGNORE_PATTERNS = [
  '\v^/usr/local/share/vim/.+/doc/',
  '\v^ginedit://',
  $'\V\^{PLUGINS_ROOT_DIRPATH}/\.\+/doc/',
  $'\V\^{SESSIONS_BASEDIR_PATH}/\.\+/{SESSION_NAME_PATTERN}',
  $'\V\^{VIEW_DIRPATH}/',
]

export def Predicate(filepath: string): bool
  return listUtil.All(IGNORE_PATTERNS, (pattern) => filepath !~# pattern)
enddef
