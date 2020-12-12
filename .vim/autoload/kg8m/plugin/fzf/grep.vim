" Respect `$RIPGREP_EXTRA_OPTIONS` (Fzf's `:Rg` doesn't respect it)
function kg8m#plugin#fzf#grep#run(pattern, dirpath) abort  " {{{
  let pattern      = shellescape(a:pattern)
  let dirpath      = empty(a:dirpath) ? "" : shellescape(a:dirpath)
  let grep_args    = pattern.." "..dirpath
  let grep_options = s:options()
  let fzf_options  = #{
  \   options: [
  \     "--header", "Grep: "..grep_args,
  \     "--delimiter", ":",
  \     "--preview-window", "right:50%:wrap:nohidden:+{2}-/2",
  \     "--preview", kg8m#plugin#get_info("fzf.vim").path.."/bin/preview.sh {}",
  \   ],
  \ }

  call fzf#vim#grep("rg "..grep_options.." "..grep_args, v:true, fzf_options)
endfunction  " }}}

function kg8m#plugin#fzf#grep#input_dir() abort  " {{{
  let dirpath = input("Specify dirpath: ", "", "dir")->expand()

  if empty(dirpath)
    throw "Dirpath not specified."
  elseif !isdirectory(dirpath)
    throw "Dirpath doesn't exist."
  else
    return dirpath
  endif
endfunction  " }}}

function s:options() abort  " {{{
  let base = "--column --line-number --no-heading --color=always"

  if empty($RIPGREP_EXTRA_OPTIONS)
    return base
  else
    let splitted = split($RIPGREP_EXTRA_OPTIONS, " ")
    let escaped  = map(splitted, { _, option -> shellescape(option) })
    return base.." "..join(escaped, " ")
  endif
endfunction  " }}}
