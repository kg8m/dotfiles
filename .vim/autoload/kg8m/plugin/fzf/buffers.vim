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
      "--header-lines", empty(kg8m#plugin#fzf#current_filepath()) ? 0 : 1,
      "--prompt", "Buffers> ",
      "--preview", "git cat {}",
      "--preview-window", "right:50%:wrap:nohidden",
    ],
  }

  fzf#run(fzf#wrap("buffer-files", options))
enddef  # }}}

def s:candidates(): list<string>  # {{{
  const current = [kg8m#plugin#fzf#current_filepath()]->filter((_, filepath) => !empty(filepath))
  const buffers = s:list()

  return kg8m#util#list_module().uniq(current + buffers)
enddef  # }}}

def s:list(): list<string>  # {{{
  return getbufinfo({ buflisted: true })
    ->filter((_, bufinfo) => !empty(bufinfo.name))
    ->mapnew((_, bufinfo) => bufinfo.name->fnamemodify(kg8m#plugin#fzf#filepath_format()))
    ->sort()
enddef  # }}}
