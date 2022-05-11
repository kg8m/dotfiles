vim9script

kg8m#plugin#EnsureSourced("fzf.vim")

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
# Also see configs for yankround.vim

export def Run(): void
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  Candidates(),
    sink:    funcref("Handler"),
    options: [
      "--no-multi",
      "--nth", "2..",
      "--prompt", "Yank> ",
      "--tabstop", "1",

      # Use `echo -E` to show backslashes.
      "--preview", "echo -E {} | sd '^ *[0-9]+\t' '' | sd '\\\\n' '\n'",

      "--preview-window", "down:10:wrap:nohidden",
    ],
  }

  kg8m#plugin#fzf#Run(() => fzf#run(fzf#wrap("yank-history", options)))
enddef

# https://github.com/svermeulen/vim-easyclip/issues/62#issuecomment-158275008
def Candidates(): list<string>
  return range(0, len(kg8m#plugin#yankround#Cache()) - 1)->mapnew((_, index) => FormatListItem(index))
enddef

def FormatListItem(index: number): string
  const text = kg8m#plugin#yankround#CacheAndRegtype(index)[0]

  # Avoid shell's syntax error in fzf's preview
  const sanitized_text = substitute(text, "\n", "\\\\n", "g")

  return printf("%3d\t%s", index, sanitized_text)
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