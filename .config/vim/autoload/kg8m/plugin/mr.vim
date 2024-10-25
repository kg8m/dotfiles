vim9script

import autoload "kg8m/plugin/startify.vim"

const PLUGINS_ROOT_DIRPATH = simplify($"{$VIM_PLUGINS}/..")
const SESSIONS_BASEDIR_PATH = startify.SESSIONS_BASEDIR_PATH
const SESSION_NAME_PATTERN = startify.SessionFilename("")
const VIEW_DIRPATH = expand(&viewdir)
const IGNORE_PATTERN = [
  '\v^/usr/local/share/vim/.+/doc/',
  '\v^ginedit://',
  $'\V\^{PLUGINS_ROOT_DIRPATH}/\.\+/doc/',
  $'\V\^{SESSIONS_BASEDIR_PATH}/\.\+/{SESSION_NAME_PATTERN}',
  $'\V\^{VIEW_DIRPATH}/',
]->join('\v|')

export def Predicate(filepath: string): bool
  return filepath !~# IGNORE_PATTERN
enddef
