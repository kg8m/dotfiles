vim9script

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
def kg8m#plugin#yankround#fzf#list(): list<string>  # {{{
  return range(0, len(g:_yankround_cache) - 1)->mapnew((_, item) => s:format_list_item(item))
enddef  # }}}

def kg8m#plugin#yankround#fzf#preview_command(): string  # {{{
  const command = "echo {}"
    .. " | sed -e 's/^ *[0-9]\\{1,\\}\t//' -e 's/\\\\/\\\\\\\\/g'"
    .. " | head -n5"

  return command
enddef  # }}}

# Overwrite current register `"`
def kg8m#plugin#yankround#fzf#handler(yank_item: string): void  # {{{
  const index = matchlist(yank_item, '\v^\s*(\d+)\t')[1]
  [text, regtype] = yankround#_get_cache_and_regtype(index)
  setreg('"', text, regtype)
  execute 'normal! ""p'
enddef  # }}}

def s:format_list_item(index: number): string  # {{{
  const text  = yankround#_get_cache_and_regtype(index)[0]

  # Avoid shell's syntax error in fzf's preview
  const sanitized_text = substitute(text, "\n", "\\\\n", "g")

  return printf("%3d\t%s", index, sanitized_text)
enddef  # }}}
