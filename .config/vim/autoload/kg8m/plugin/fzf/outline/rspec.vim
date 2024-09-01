vim9script

import autoload "kg8m/util/logger.vim"
import autoload "kg8m/plugin/fzf/buffer_lines.vim" as fzfBufferLines

const QUERY = '''context'' | ''describe''  | ''example''  | ''it'' ''do'' | \ it\ " | \ it\ '' | \ it\ { '

export def Run(): void
  if expand("%") !~# '\w_spec\.rb$'
    logger.Error("Not an RSpec file.")
    return
  endif

  fzfBufferLines.Run(QUERY)
enddef
