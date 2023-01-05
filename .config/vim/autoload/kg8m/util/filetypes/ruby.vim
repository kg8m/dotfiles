vim9script

# Copy `Foo::Bar::Baz` from
#
#   module Foo
#     class Bar
#       module Baz
#       end
#     end
#   end
#
# cf. https://github.com/ujihisa/config/blob/dc95c0a8b8be6722a98dd9acd916271fa507d25d/_vimrc#L2921-L2931

import autoload "kg8m/util.vim"
import autoload "kg8m/util/list.vim" as listUtil
import autoload "kg8m/util/logger.vim"

const PATTERN = '\v^\s*(class|module)\s+\zs(\k|[:])+'

final cache = {}

export def CopyNestedClassName(): void
  cache.prev_indentation = null
  const name = getline("'<", "'>")->reverse()->listUtil.FilterMap(Extract)->reverse()->join("::")

  if empty(name)
    logger.Warn("No class/module name found in selected text.")
  else
    util.RemoteCopy(name)
  endif
enddef

def Extract(line: string): any
  const match = matchstr(line, PATTERN)

  if match ==# ""
    return false
  endif

  const indentation = matchstr(line, '^\zs\s*')

  if cache.prev_indentation ==# null || len(indentation) <# len(cache.prev_indentation)
    cache.prev_indentation = indentation
    return match
  else
    return false
  endif
enddef
