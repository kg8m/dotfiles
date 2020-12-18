vim9script

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
def kg8m#plugin#yankround#fzf#list(): list<string>  # {{{
  return range(0, len(g:_yankround_cache) - 1)->map("s:format_list_item(v:val)")
enddef  # }}}

def kg8m#plugin#yankround#fzf#preview_command(): string  # {{{
  const command = "echo {}"
    .. " | sed -e 's/^ *[0-9]\\{1,\\}\t//' -e 's/\\\\/\\\\\\\\/g'"
    .. " | head -n5"

  return command
enddef  # }}}

def kg8m#plugin#yankround#fzf#handler(yank_item: string): void  # {{{
  const old_reg = [getreg('"'), getregtype('"')]
  const index = matchlist(yank_item, '\v^\s*(\d+)\t')[1]
  [text, regtype] = yankround#_get_cache_and_regtype(index)
  setreg('"', text, regtype)

  try
    execute 'normal! ""p'
  finally
    setreg('"', old_reg[0], old_reg[1])
  endtry
enddef  # }}}

def s:format_list_item(index: number): string  # {{{
  const text  = yankround#_get_cache_and_regtype(index)[0]

  # Avoid shell's syntax error in fzf's preview
  const sanitized_text = substitute(text, "\n", "\\\\n", "g")

  return printf("%3d\t%s", index, sanitized_text)
enddef  # }}}
