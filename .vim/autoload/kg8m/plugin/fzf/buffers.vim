vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Sort buffers in dictionary order (Fzf's `:Buffers` doesn't sort them)
def kg8m#plugin#fzf#buffers#run(): void  # {{{
  # Use `final` instead of `const` because the variable will be changed by fzf
  final options = {
    source:  s:candidates(),
    options: [
      "--header-lines", empty(kg8m#util#file#current_path()) ? 0 : 1,
      "--prompt", "Buffers> ",
      "--preview", "git cat {}",
      "--preview-window", "right:50%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("buffer-files", options))
enddef  # }}}

def s:candidates(): list<string>  # {{{
  const current = [kg8m#util#file#current_path()]->filter((_, filepath) => !empty(filepath))
  const buffers = s:list()

  return kg8m#util#list#vital().uniq(current + buffers)
enddef  # }}}

def s:list(): list<string>  # {{{
  const MapperCallback = (bufinfo) => empty(bufinfo.name) ? false : kg8m#util#file#format_path(bufinfo.name)
  return getbufinfo({ buflisted: true })->kg8m#util#list#filter_map(MapperCallback)->sort()
enddef  # }}}
