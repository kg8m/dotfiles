vim9script

# Manually source the plugin because dein.vim's `on_func` feature is not available.
# Vim9 script doesn't support `FuncUndefined` event: https://github.com/vim/vim/issues/7501
if !kg8m#plugin#is_sourced("fzf.vim")
  kg8m#plugin#source("fzf.vim")
endif

# Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)
def kg8m#plugin#fzf#grep#run(pattern: string, dirpath: string): void  # {{{
  const escaped_pattern = shellescape(pattern)
  const escaped_dirpath = empty(dirpath) ? "" : shellescape(dirpath)
  const grep_args       = escaped_pattern .. " " .. escaped_dirpath
  const grep_options    = s:options()

  # Use `final` instead of `const` because the variable will be changed by fzf
  final fzf_options = {
    options: [
      "--header", "Grep: " .. grep_args,
      "--delimiter", ":",
      "--preview-window", "right:50%:wrap:nohidden:+{2}-/2",
      "--preview", kg8m#plugin#get_info("fzf.vim").path .. "/bin/preview.sh {}",
    ],
  }

  fzf#vim#grep("rg " .. grep_options .. " " .. grep_args, true, fzf_options)
enddef  # }}}

def kg8m#plugin#fzf#grep#input_dir(): string  # {{{
  const dirpath = input("Specify dirpath: ", "", "dir")->expand()

  if empty(dirpath)
    echoerr "Dirpath not specified."
  elseif !isdirectory(dirpath)
    echoerr "Dirpath doesn't exist."
  endif

  return dirpath
enddef  # }}}

def s:options(): string  # {{{
  const base = "--column --line-number --no-heading --color=always"

  if empty($RIPGREP_EXTRA_OPTIONS)
    return base
  else
    final splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
    const escaped  = map(splitted, "shellescape(v:val)")
    return base .. " " .. join(escaped, " ")
  endif
enddef  # }}}
