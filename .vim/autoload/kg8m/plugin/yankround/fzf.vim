vim9script

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
export def List(): list<string>
  return range(0, len(kg8m#plugin#yankround#Cache()) - 1)->mapnew((_, index) => FormatListItem(index))
enddef

export def PreviewCommand(): string
  return "echo {} | sed -e 's/^ *[0-9]\\{1,\\}\t//' -e 's/\\\\/\\\\\\\\/g'"
enddef

# Overwrite current register `"`
export def Handler(yank_item: string): void
  const index   = matchlist(yank_item, '\v^\s*(\d+)\t')[1]->str2nr()
  const cache   = kg8m#plugin#yankround#CacheAndRegtype(index)
  const text    = cache[0]
  const regtype = cache[1]

  setreg('"', text, regtype)
  execute 'normal! ""p'
enddef

def FormatListItem(index: number): string
  const text  = kg8m#plugin#yankround#CacheAndRegtype(index)[0]

  # Avoid shell's syntax error in fzf's preview
  const sanitized_text = substitute(text, "\n", "\\\\n", "g")

  return printf("%3d\t%s", index, sanitized_text)
enddef
